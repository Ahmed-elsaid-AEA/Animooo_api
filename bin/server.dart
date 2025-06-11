import 'package:animooo_api/core/dotenv_service.dart';
import 'package:vania/vania.dart';
import 'package:animooo_api/config/app.dart';
 
void main() async {
  await DotenvService.init();
  print(DotenvService.getDbName());
  Application().initialize(config: config);
}
