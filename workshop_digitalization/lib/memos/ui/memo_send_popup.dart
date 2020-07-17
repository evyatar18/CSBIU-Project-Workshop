import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:workshop_digitalization/memos/memo_sender.dart';

import '../memo.dart';

Future<void> showMemoSendPopup(BuildContext context, Memo memo, List<String> recipients) async {
  // final includeFiles = await showAgreementDialog(context, "Include memo files", barrierDismissible: true);

  // // user dismissed the dialog
  // if (includeFiles == null) {
  //   return;
  // }

  final includeFiles = false;

  final email = await createMemoEmail(memo: memo, attachFiles: includeFiles, recipients: recipients);
  await FlutterEmailSender.send(email);
}