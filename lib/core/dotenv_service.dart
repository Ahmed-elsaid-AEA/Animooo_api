import 'package:dotenv/dotenv.dart';

class DotenvService {
  static late final DotEnv dotEnv;
  static Future<void> init() async =>
      dotEnv = DotEnv(includePlatformEnvironment: true)..load();

  static String getDbName() => dotEnv['DB_DATABASE'].toString();
  static String getDBHOST() => dotEnv['DB_HOST'].toString();
  static String getDBUser() => dotEnv['DB_USERNAME'].toString();
  static int getDBPort() => int.parse(dotEnv['DB_PORT'].toString());
  static String getDBPassword() => dotEnv['DB_PASSWORD'].toString();
  static String getJwtSecret() => dotEnv['JWT_SECRET'].toString();
  static String getAppUrl() => dotEnv['APP_URL'].toString();
  static String getMailFromAddress() => dotEnv['MAIL_FROM_ADDRESS'].toString();

  static String? getAppName() => dotEnv['MAIL_FROM_NAME'].toString();
}
