import 'package:workshop_digitalization/global/emails.dart';

import 'memo.dart';
// Send the memo on the email
Future<void> openMemoEmail({Memo memo, List<String> recipients}) {
  final email = Email(to: recipients, subject: memo.topic, body: memo.content);
  return email.send();
}