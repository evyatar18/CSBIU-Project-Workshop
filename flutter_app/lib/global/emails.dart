import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class Email {
  String subject;
  List<String> to;
  List<String> cc;
  List<String> bcc;
  String body;

  Email({
    this.subject = "",
    List<String> to = const <String>[],
    List<String> cc = const <String>[],
    List<String> bcc = const <String>[],
    this.body = "",
  })  : this.to = List.of(to)..removeWhere(_isMailformed),
        this.cc = List.of(cc)..removeWhere(_isMailformed),
        this.bcc = List.of(bcc)..removeWhere(_isMailformed);
  // check if mail is valid
  static bool _isMailformed(String email) {
    return email == null || email.isEmpty || !email.contains("@");
  }

  Future<void> send() {
    if (to.isEmpty) {
      return Future.error("No valid emails were supplied");
    }

    final mail = Mailto(to: to, cc: cc, bcc: bcc, body: body, subject: subject);

    return launch("$mail");
  }
}
