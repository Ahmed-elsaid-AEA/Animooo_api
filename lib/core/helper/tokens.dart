import 'package:animooo_api/app/models/user_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/user_crud.dart';
import 'package:animooo_api/core/dotenv_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<({bool isValid, String? email, int? id})> tokenIsValid(
  String token,
) async {
  try {
    final jwt = JWT.verify(token, SecretKey(DotenvService.getJwtSecret()));
    final userId = jwt.payload[ConstsValues.kId];
    final email = jwt.payload[ConstsValues.kEmail];
    // اكمل المعالجة باستخدام userId و email
    UserModel? userModel = await UserCrud().findUsingEmail(
        UserModel.fromAccessToken(accessToken: token, email: email));
    print(userModel);
    if (userModel == null) {
      return (isValid: false, email: null, id: null);
    } else {
      return (
        isValid: true,
        email: email.toString(),
        id: int.parse(userId.toString())
      );
    }
  } catch (e) {
    return (isValid: false, email: null, id: null);
  }
}
