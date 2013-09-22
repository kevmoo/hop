library hop_experimental;

import 'dart:async';
import 'dart:io';
import 'package:html5lib/dom.dart' as dom;
import 'package:html5lib/parser.dart';

Future<bool> transformHtml(String filePath,
    Future<dom.Document> transformer(dom.Document doc)) {

  return transformFile(filePath, (String content) {
    var parser = new HtmlParser(content, generateSpans: true);
    var document = parser.parse();

    return transformer(document)
        .then((dom.Document newDoc) {
          return newDoc.outerHtml;
        });
  });
}

Future<bool> transformFile(String filePath,
    Future<String> transformer(String input)) {

  String oldContent;

  final file = new File(filePath);
  return FileSystemEntity.type(filePath)
      .then((FileSystemEntityType fseType) {
        if(fseType == FileSystemEntityType.FILE) {
          return file.readAsString();
        } else if(fseType == FileSystemEntityType.NOT_FOUND) {
          return null;
        } else {
          throw new UnsupportedError('Cannot overwrite existing entity of'
              ' type $fseType');
        }
      })
      .then((String value) {
        oldContent = value;
        return transformer(oldContent);
      })
      .then((String newContent) {
        // we're assuming file hasn't changed since we started
        if(newContent == oldContent) {
          // nothing changed
          return false;
        } else {
          return file.writeAsString(newContent, mode: FileMode.WRITE)
              .then((_) => true);
        }
      });
}
