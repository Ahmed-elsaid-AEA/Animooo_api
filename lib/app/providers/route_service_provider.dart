import 'dart:io';

import 'package:animooo_api/core/dotenv_service.dart';
import 'package:vania/vania.dart';
import 'package:animooo_api/route/api_route.dart';
import 'package:animooo_api/route/web.dart';
import 'package:animooo_api/route/web_socket.dart';

class RouteServiceProvider extends ServiceProvider {
  @override
  Future<void> boot() async {
    final host = DotenvService.getAppHost();
    final port = DotenvService.getAppPort();
    print('✅ Custom Server started on http://$host:$port');
  }

  @override
  Future<void> register() async {
    WebRoute().register();
    ApiRoute().register();
    WebSocketRoute().register();
  }
}
