library hop_tasks.git;

import 'dart:async';
import 'package:path/path.dart' as pathos;
import 'package:bot/bot.dart';
import 'package:bot_io/bot_git.dart';
import 'package:hop/hop_core.dart';

Task getBranchForDirTask(String sourceBranch, String sourceDir,
                         String targetBranch, {String workingDir}) {
  requireArgumentNotNullOrEmpty(sourceBranch, 'sourceBranch');
  requireArgumentNotNullOrEmpty(sourceDir, 'sourceDir');
  requireArgumentNotNullOrEmpty(targetBranch, 'targetBranch');

  final description = 'Commit the tree for dir "$sourceDir" in branch'
      ' "$sourceBranch" and create/update branch "$targetBranch" with the new commit';

  return new Task((ctx) =>
      branchForDir(ctx, sourceBranch, sourceDir, targetBranch, workingDir: workingDir),
      description: description);
}

Future branchForDir(TaskContext ctx, String sourceBranch, String sourceDir,
    String targetBranch, {String workingDir}) {

  if(workingDir == null) {
    workingDir = pathos.current;
  }

  GitDir gitDir;

  String sourceDirTreeSha;
  String commitMsg;

  return GitDir.fromExisting(workingDir)
      .then((GitDir value) {
        gitDir = value;

        return gitDir.lsTree(sourceBranch, subTreesOnly: true, path: sourceDir);
      })
      .then((List<TreeEntry> entries) {
        assert(entries.length <= 1);
        if(entries.isEmpty) {
          throw 'Could not find a matching dir on the provided branch';
        }

        final tree = entries.single;

        sourceDirTreeSha = tree.sha;

        // get the commit SHA for the source branch for the commit MSG
        return gitDir.getBranchReference(sourceBranch);
      })
      .then((BranchReference sourceBranchRef) {
        final sourceBranchCommitShortSha = sourceBranchRef.sha.substring(0, 8);
        commitMsg = 'Contents of $sourceDir from commit $sourceBranchCommitShortSha';

        return gitDir.createOrUpdateBranch(targetBranch, sourceDirTreeSha, commitMsg);
      })
      .then((String newCommitSha) {
        if(newCommitSha == null) {
          ctx.fine('There have been no changes to "$sourceDir" since the last commit');
        } else {
          ctx.info("Branch '$targetBranch' is now at commit $newCommitSha");
        }
      });
}
