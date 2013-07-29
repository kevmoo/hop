library hop_tasks_experimental;

import 'dart:async';
import 'dart:io';
import 'dart:json' as json;
import 'package:hop/hop.dart';
import 'package:path/path.dart' as path;
import 'package:html5lib/dom.dart';

import 'package:hop/src/hop_experimental.dart';

const _sourceTitle = 'Dart Documentation';

const _outputTitle = 'Hop Documentation';
const _tagLine = 'Hop - A Dart framework for reusable, object-oriented tasks';
const _sourceHref = 'https://github.com/kevmoo/hop.dart';

bool _myLibFilter(String libName) {
  return libName.startsWith('hop');
}

Future postBuild(TaskLogger logger, String tempDocDir) {

  final indexPath = path.join(tempDocDir, 'index.html');

  logger.info('Updating main page');
  return transformHtml(indexPath, _updateIndex)
      .then((_) {
        logger.info('Fixing titles');
        return _updateTitles(tempDocDir);
      })
      .then((_) {
        logger.info('Copying resources');
        // TODO: make this non-bash specific
        return Process.run('bash', ['-c', 'cp resource/* $tempDocDir']);
      })
      .then((ProcessResult pr) {
        assert(pr.exitCode == 0);

        logger.info('Fixing apidoc.json');
        final apiDocJsonPath = path.join(tempDocDir, 'nav.json');
        assert(FileSystemEntity.isFileSync(apiDocJsonPath));
        return transformFile(apiDocJsonPath, _fixApiDoc);
      });
}

Future<String> _fixApiDoc(String jsonInput) {

  List navList = json.parse(jsonInput);

  var navMap = new Map<String, Map>();

  for(var foo in navList) {
    var name = foo['name'];
    navMap[name] = foo;
  }

  var sorted = navMap.keys.toList()
      ..sort();

  navList = sorted.map((String name) => navMap[name])
      .toList();

  jsonInput = json.stringify(navList);

  return new Future.value(jsonInput);
}

Future _updateTitles(String tempDocDir) {
  final dir = new Directory(tempDocDir);
  return dir.list(recursive:true)
      .where((FileSystemEntity fse) => fse is File)
      .map((File f) => f.path)
      .where((String path) => path.endsWith('.html'))
      .toList()
      .then((List<String> files) {
        return Future.forEach(files, (String filePath) {
          return transformFile(filePath, _updateTitle);
        });
      });
}

Future<String> _updateTitle(String source) {
  final weirdDoubleTitle = '$_sourceTitle / $_sourceTitle';
  source = source.replaceAll(weirdDoubleTitle, _sourceTitle);

  source = source.replaceAll(_sourceTitle, _outputTitle);
  return new Future<String>.value(source);
}

Future<Document> _updateIndex(Document source) {
  final contentDiv = source.queryAll('div')
      .singleWhere((Element div) => div.attributes['class'] == 'content');

  // should only have h3 and h4 elements
  final targetLibraryHeaders = new Map<String, Element>();
  final otherHeaders = new Map<String, Element>();

  for(final child in contentDiv.children) {
    assert(child.tagName == 'h2' || child.tagName == 'h3' || child.tagName == 'h4');

    if(child.tagName == 'h4') {
      assert(child.children.length == 1);

      final anchor = child.children[0];
      assert(anchor.tagName == 'a');

      final libName = anchor.innerHtml;

      if(_myLibFilter(libName)) {
        targetLibraryHeaders[libName] = child;
      } else {
        otherHeaders[libName] = child;
      }
    }
  }

  contentDiv.children.clear();

  contentDiv.children.add(_getAboutElement());

  final doSection = (String name, Map<String, Element> sectionContent) {
    if(!sectionContent.isEmpty) {
      contentDiv.children.add(new Element.tag('h3')
        ..innerHtml = name);

      var orderedSectionKeys = sectionContent.keys
          .toList(growable: false)
          ..sort();

      for(var k in orderedSectionKeys) {
        contentDiv.children.add(sectionContent[k]);
      }
    }

  };

  doSection(_tagLine, targetLibraryHeaders);
  doSection('Dependencies', otherHeaders);

  return new Future<Document>.value(source);
}

Element _getAboutElement() {
  final logo = new Element.tag('img')
    ..attributes['src'] = 'logo.png'
    ..attributes['width'] = '500'
    ..attributes['height'] = '304'
    ..attributes['title'] = _tagLine;

  final logoLink = new Element.tag('a')
    ..attributes['href'] = _sourceHref
    ..children.add(logo);

  final sourceLabel = new Element.tag('strong')
    ..innerHtml = 'Source code: ';

  final ghLink = new Element.tag('a')
  ..attributes['href'] = _sourceHref
  ..innerHtml = _sourceHref;

  return new Element.tag('div')
    ..attributes['class'] = 'about'
    ..children.add(logoLink)
    ..children.add(new Element.tag('br'))
    ..children.add(sourceLabel)
    ..children.add(ghLink);
}
