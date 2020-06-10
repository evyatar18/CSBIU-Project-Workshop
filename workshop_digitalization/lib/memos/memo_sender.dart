import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'memo.dart';

Future<Email> createMemoEmail(
    {Memo memo, List<String> recipients, bool attachFiles}) async {
  List<String> filePaths;

  if (attachFiles) {
    final files = await memo.attachedFiles.files.first;

    final fileDownloads = files
        .map((file) => file.getFile().last)
        .map((snapshot) async => (await snapshot).file)
        .map((file) async => (await file).path)
        .toList();

    filePaths = await Future.wait(fileDownloads);
    print(filePaths);
  }

  return Email(
    subject: memo.topic,
    body: memo.content,
    isHTML: true,
    recipients: recipients,
    attachmentPaths: filePaths,
  );
}

