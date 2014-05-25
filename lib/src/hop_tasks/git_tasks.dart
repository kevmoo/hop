@deprecated
library hop_tasks.git;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:hop_git/hop_git.dart' as hg;

/// **DEPRECATED**. Use `hop_git` package instead.
///
/// Creates a [Task] which creates and populates a branch with [sourceDir].
///
/// The contents of [sourceDir] on the [sourceBranch] are used to create or
/// update [targetBranch].
///
/// This task wraps [branchForDir] and provides a description.
@deprecated
Task getBranchForDirTask(String sourceBranch, String sourceDir,
                         String targetBranch, {String workingDir}) {
  return hg.getBranchForDirTask(sourceBranch, sourceDir, targetBranch,
      workingDir: workingDir);
}


/// **DEPRECATED**. Use `hop_git` package instead.
///
/// Creates and populates a branch with [sourceDir].
///
/// The contents of [sourceDir] on the [sourceBranch] are used to create or
/// update [targetBranch].
///
/// [getBranchForDirTask] wraps this into a [Task] and provides a description.
@deprecated
Future branchForDir(TaskContext ctx, String sourceBranch, String sourceDir,
    String targetBranch, {String workingDir}) {
  return hg.branchForDir(ctx, sourceBranch, sourceDir, targetBranch,
      workingDir: workingDir);
}
