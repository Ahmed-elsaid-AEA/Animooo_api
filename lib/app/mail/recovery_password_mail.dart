import 'package:animooo_api/core/dotenv_service.dart';
import 'package:vania/vania.dart';

class RecoveryPasswordMail extends Mailable {
  final String to;
  final String text;
  final String subject;

  const RecoveryPasswordMail(
      {required this.to, required this.text, required this.subject});

  @override
  List<Attachment>? attachments() {
    return null;
  }

  @override
  Content content() {
    return Content(
      text: text,
    );
  }

  @override
  Envelope envelope() {
    return Envelope(
      from: Address(
          DotenvService.getMailFromAddress(), DotenvService.getAppName()),
      to: [Address(to)],
      subject: subject,
    );
  }
}
