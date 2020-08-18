import 'package:workshop_digitalization/global/emails.dart';

import 'memo.dart';

Future<void> openMemoEmail({Memo memo, List<String> recipients}) {
  final email = Email(to: recipients, subject: memo.topic, body: memo.content);
  return email.send();
}