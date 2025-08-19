import 'package:animooo_api/core/dotenv_service.dart';
import 'package:mysql1/mysql1.dart';

class DBConnections {
  static Future<MySqlConnection> connect() async {
    final settings = ConnectionSettings(
      host: DotenvService.getDBHOST(),
      port: DotenvService.getDBPort(),
      user: DotenvService.getDBUser(),
      password: DotenvService.getDBPassword() .isEmpty ? null : DotenvService.getDBPassword(),
      db: DotenvService.getDbName(),
    );
    return await MySqlConnection.connect(settings);
  }

  static Future<void> closeDbConnection(MySqlConnection conn) async {
    await conn.close();
  }
}
