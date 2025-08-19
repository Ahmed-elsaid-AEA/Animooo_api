import 'dart:io';
import 'package:animooo_api/app/mail/recovery_password_mail.dart';
import 'package:animooo_api/app/models/user_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/user_crud.dart';
import 'package:animooo_api/core/dotenv_service.dart';
import 'package:animooo_api/core/helper/hash_password.dart';
import 'package:animooo_api/core/helper/random_helper.dart';
import 'package:animooo_api/core/helper/show_images.dart';
import 'package:animooo_api/core/helper/store_images.dart';
import 'package:animooo_api/core/helper/tokens.dart';
import 'package:animooo_api/core/helper/validation_helper.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';
import 'package:vania/vania.dart';

final userController = UserController();

class UserController {
  Future<Response> forgetPassword(Request request) async {
    final email = request.input(ConstsValues.kEmail)?.toString().trim();

    if (email == null) {
      return Response.json(
          {ConstsValues.kMessage: ConstsValues.kEmailIsRequired});
    } else {
      String code = generateRandomCode(5);

      UserCrud userCrud = UserCrud();
      UserModel? userModel = await userCrud
          .update(UserModel.verfiy(email: email, verificationCode: code));
      if (userModel == null) {
        return Response.json(
            {ConstsValues.kMessage: ConstsValues.kInvalidEmail});
      } else {
        await sendPasswordRecoveryCode(email, code);
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.ok,
          ConstsValues.kMessage: ConstsValues.kEmailSentSuccessfully
        });
      }
    }
  }

  Future<Response> signup(Request request) async {
    print('request: $request');
    final firstName = request.input(ConstsValues.kFirstName)?.toString().trim();
    final lastName = request.input(ConstsValues.kLastName)?.toString().trim();
    final email = request.input(ConstsValues.kEmail)?.toString().trim();
    final phone = request.input(ConstsValues.kPhone)?.toString().trim();
    final password = request.input(ConstsValues.kPassword)?.toString().trim();
    //???
    final imageFile = request.file(ConstsValues.kImage);
    // ✅ Validation

    // ✅ check if any field is null
    List<String> requiredText = [
      if (firstName == null) ConstsValues.kFirstNameIsRequired,
      if (lastName == null) ConstsValues.kLastNameIsRequired,
      if (email == null) ConstsValues.kEmailIsRequired,
      if (phone == null) ConstsValues.kPhoneIsRequired,
      if (password == null) ConstsValues.kPasswordIsRequired,
      if (imageFile == null) ConstsValues.kImageIsRequired
    ];

    // ✅ check if any field is empty
    if (requiredText.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredText,
      }, HttpStatus.badRequest);
    }
    // ✅ check if email is valid
    // ✅ check if password is valid
    // ✅ check if phone is valid
    requiredText = [
      if (!ValidationHelper.isVaildEmail(email!)) ConstsValues.kInvalidEmail,
      if (!ValidationHelper.isPasswordValidate(password!))
        ConstsValues
            .kPasswordMustBeAtLeast6CharactersAndIncludeLettersAndNumbers,
      if (!ValidationHelper.isValidPhoneNumber(phone!))
        ConstsValues.kInvalidPhone
    ];
    if (requiredText.isNotEmpty) {
      return Response.json(
        {
          ConstsValues.kStatusCode: HttpStatus.badRequest,
          ConstsValues.kError: requiredText,
        },
        HttpStatus.badRequest,
      );
    }
    // ✅ Save image
    String? imageUrl = await StoreImages.call(imageFile!);
    //✅ Hash password
    final hashedPassword = HashPassword.call(password);
    //? Generate verification code
    String verficationCode = generateRandomCode(5);
    // ✅ Store in DB
    UserCrud userCrud = UserCrud();
    UserModel? userModel = await userCrud.create(UserModel(
        verificationCode: verficationCode,
        firstName: firstName!,
        lastName: lastName!,
        email: email,
        phone: phone,
        hashPassword: hashedPassword,
        imagePath: imageUrl,
        id: -1));
    if (userModel == null) {
      return Response.json(
        {
          ConstsValues.kStatusCode: HttpStatus.badRequest,
          ConstsValues.kError: [
            ConstsValues.kEmailAlreadyExistsOrDatabaseError
          ],
        },
        HttpStatus.badRequest,
      );
    } else {
      final userId = userModel.id;
      // ✅ Generate tokens
      await sendPasswordRecoveryCode(email, verficationCode);

      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.created,
        ConstsValues.kMessage: ConstsValues.kSignupSuccessful,
        ConstsValues.kAlert: ConstsValues.kWeSendVerficationCodeToYourEmail,
        ConstsValues.kUser: {
          ConstsValues.kId: userId,
          ConstsTables.kFirstName: firstName,
          ConstsTables.kLastName: lastName,
          ConstsTables.kEmail: email,
          ConstsTables.kPhone: phone,
          ConstsTables.kImagePath: imageUrl,
          ConstsTables.kIsVerified: "false"
        }
      });
    }
  }

  Future<Response> createNewVerficationCode(Request request) async {
    final email = request.input(ConstsValues.kEmail)?.toString().trim();
    //???

    // ✅ check if any field is null
    List<String> requiredText = [
      if (email == null) ConstsValues.kEmailIsRequired,
    ];

    // ✅ check if any field is empty
    if (requiredText.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredText,
      }, HttpStatus.badRequest);
    }
    // ✅ check if email is valid
    requiredText = [
      if (!ValidationHelper.isVaildEmail(email!)) ConstsValues.kInvalidEmail,
    ];
    if (requiredText.isNotEmpty) {
      return Response.json(
        {
          ConstsValues.kStatusCode: HttpStatus.badRequest,
          ConstsValues.kError: requiredText,
        },
        HttpStatus.badRequest,
      );
    }
    //? Generate verification code
    String verficationCode = generateRandomCode(5);
    // ✅ Store in DB
    UserCrud userCrud = UserCrud();
    UserModel? userModel =
        await userCrud.updateVerification(UserModel.fromVerficationCode(
      verificationCode: verficationCode,
      email: email,
    ));
    if (userModel == null) {
      return Response.json(
        {
          ConstsValues.kStatusCode: HttpStatus.badRequest,
          ConstsValues.kError: [ConstsValues.kThisEmailNotFound],
        },
        HttpStatus.badRequest,
      );
    } else {
      final userId = userModel.id;
      // ✅ Generate tokens
      await sendPasswordRecoveryCode(email, verficationCode);

      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.created,
        ConstsValues.kMessage: ConstsValues.kWeSendVerficationCodeToYourEmail,
        ConstsValues.kAlert: ConstsValues.kWeSendVerficationCodeToYourEmail,
        ConstsValues.kUser: {
          ConstsValues.kId: userId,
          ConstsTables.kEmail: email,
          ConstsTables.kIsVerified: userModel.isVerified == 1 ? "true" : "false"
        }
      });
    }
  }

  Future<Response> showImage(dynamic fileName) async {
    return ShowImages.call(fileName);
  }

  Future<void> sendPasswordRecoveryCode(String email, String code) async {
    try {
      await RecoveryPasswordMail(
        to: email,
        text: 'Your password recovery code is $code',
        subject: ConstsValues.kPasswordRecoveryCode,
      ).send();
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Future<({String accessToken, String refreshToken})> generateTokens(
      String email, int userId) async {
    final jwt = JWT({
      ConstsValues.kId: userId,
      ConstsValues.kEmail: email,
    }, issuer: DotenvService.getAppName());
    final acToken = jwt.sign(SecretKey(DotenvService.getJwtSecret()),
        expiresIn: ConstsValues.kExpiresTokenTime);
    final reToken = Uuid().v4();
    return (
      accessToken: acToken,
      refreshToken: reToken,
    );
  }

  Future<Response> otpVerficationCode(Request request) async {
    String? email = request.input('email')?.toString();
    String? code = request.body['code']?.toString();
    List<String> requiredData = [
      if (email == null) ConstsValues.kEmailIsRequired,
      if (code == null) ConstsValues.kVerficationCodeIsRequired
    ];

    if (requiredData.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredData,
      }, HttpStatus.badRequest);
    } else {
      UserCrud userCrud = UserCrud();
      UserModel? userModel = await userCrud.findVerfiyCode(
          UserModel.verfiy(email: email, verificationCode: code));
      if (userModel == null) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.badRequest,
          ConstsValues.kError: [ConstsValues.kInvalidVerficationCode],
        }, HttpStatus.badRequest);
      } else {
        //change is verified to 1
        userModel = await userCrud.update(UserModel.isVerified(
            email: email, isVerified: 1, id: userModel.id));
        ({String accessToken, String refreshToken}) tokens =
            await generateTokens(email!, userModel!.id!);
        //?update refresh token in db
        userModel = await userCrud.update(UserModel.updateRefreshToken(
            email: email,
            id: userModel.id,
            refreshToken: tokens.refreshToken,
            accessToken: tokens.accessToken));

        if (userModel == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kDatabaseError],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kMessage: ConstsValues.kVerficationSuccessful,
            ConstsTables.kAccessToken: tokens.accessToken,
            ConstsTables.kRefreshToken: tokens.refreshToken,
            ConstsValues.kUser: {
              ConstsValues.kId: userModel.id,
              ConstsTables.kFirstName: userModel.firstName,
              ConstsTables.kLastName: userModel.lastName,
              ConstsTables.kEmail: userModel.email,
              ConstsTables.kPhone: userModel.phone,
              ConstsTables.kImagePath: userModel.imagePath,
              ConstsTables.kIsVerified: "true",
            }
          });
        }
      }
    }
  }

  Future<Response> checkTokenWork(Request request) async {
    String? token = request.header(ConstsValues.kAuthorization)?.toString();
    String? email = request.header(ConstsValues.kEmail)?.toString();
    List<String> requiredData = [
      if (token == null) ConstsValues.kTokenIsRequired,
      if (email == null) ConstsValues.kEmailIsRequired
    ];

    if (requiredData.isNotEmpty) {
      return Response.json({
        ConstsValues.kError: requiredData,
        ConstsValues.kStatusCode: HttpStatus.badRequest
      }, HttpStatus.badRequest);
    } else {
      ({String? email, int? id, bool isValid})? validToken = await tokenIsValid(
        token!.replaceFirst("Bearer ", ''),
      );
      if (!validToken.isValid) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.unauthorized,
          ConstsValues.kError: [ConstsValues.kInvalidOrExpiredToken],
        }, HttpStatus.unauthorized);
      } else {
        return Response.json({
          ConstsValues.kMessage: 'Authorized user: $email',
          ConstsValues.kStatusCode: HttpStatus.ok,
        });
      }
    }
  }

  Future<Response> createNewPassword(Request request) async {
    final email = request.input(ConstsValues.kEmail)?.toString().trim();
    final password = request.input(ConstsValues.kPassword)?.toString().trim();
    final confirmPassword =
        request.input(ConstsValues.kConfirmPassword)?.toString().trim();
    List<String> requiredData = [
      if (email == null) ConstsValues.kEmailIsRequired,
      if (password == null) ConstsValues.kPasswordIsRequired,
      if (confirmPassword == null) ConstsValues.kConfirmPassword,
      if (password != confirmPassword) ConstsValues.kPasswordNotMatch
    ];
    if (requiredData.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredData,
      }, HttpStatus.badRequest);
    } else {
      requiredData = [
        if (!ValidationHelper.isVaildEmail(email!)) ConstsValues.kInvalidEmail,
        if (!ValidationHelper.isPasswordValidate(password!))
          ConstsValues
              .kPasswordMustBeAtLeast6CharactersAndIncludeLettersAndNumbers
      ];
      if (requiredData.isNotEmpty) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.badRequest,
          ConstsValues.kError: requiredData,
        }, HttpStatus.badRequest);
      }
      UserCrud userCrud = UserCrud();
      UserModel? userModel = await userCrud.update(UserModel.updatePassword(
        email: email,
        hashPassword: HashPassword.call(password),
      ));
      if (userModel == null) {
        return Response.json({
          ConstsValues.kError: [ConstsValues.kNotFoundThisEmail],
          ConstsValues.kStatusCode: HttpStatus.badRequest
        }, HttpStatus.badRequest);
      } else {
        ({String accessToken, String refreshToken}) tokens =
            await generateTokens(email, userModel.id!);
        //?update refresh token in db
        userModel = await userCrud.update(
          UserModel.updateRefreshToken(
            email: email,
            id: userModel.id,
            refreshToken: tokens.refreshToken,
            accessToken: tokens.accessToken,
          ),
        );

        if (userModel == null) {
          return Response.json({
            ConstsValues.kError: [ConstsValues.kNotFoundThisEmail],
            ConstsValues.kStatusCode: HttpStatus.badRequest
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kMessage: ConstsValues.kPasswordUpdatedSuccessfully,
            ConstsTables.kAccessToken: tokens.accessToken,
            ConstsTables.kRefreshToken: tokens.refreshToken,
            ConstsValues.kUser: {
              ConstsValues.kId: userModel.id,
              ConstsTables.kFirstName: userModel.firstName,
              ConstsTables.kLastName: userModel.lastName,
              ConstsTables.kEmail: userModel.email,
              ConstsTables.kPhone: userModel.phone,
              ConstsTables.kImagePath: userModel.imagePath,
              ConstsTables.kIsVerified: "true",
            }
          });
        }
      }
    }
  }

  Future<Response> login(Request request) async {
    final email = request.input(ConstsValues.kEmail)?.toString().trim();
    final password = request.input(ConstsValues.kPassword)?.toString().trim();
    List<String> requiredData = [
      if (email == null) ConstsValues.kEmailIsRequired,
      if (password == null) ConstsValues.kPasswordIsRequired,
    ];
    if (requiredData.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredData,
      }, HttpStatus.badRequest);
    } else {
      return _loginWork(email!, password!);
    }
  }

  Future<Response> _loginWork(String email, String password) async {
    UserCrud userCrud = UserCrud();
    UserModel? userModel = await userCrud.findUsingMailAndPassword(
      UserModel.login(email: email, hashPassword: HashPassword.call(password)),
    );
    if (userModel == null) {
      return Response.json({
        ConstsValues.kError: [ConstsValues.kPassowrdOrEMailNotTrue],
        ConstsValues.kStatusCode: HttpStatus.badRequest
      }, HttpStatus.badRequest);
    } else if (userModel.isVerified == 0) {
      return Response.json({
        ConstsValues.kError: [ConstsValues.kAccountNotVerified],
        ConstsValues.kStatusCode: HttpStatus.badRequest
      });
    } else {
      ({String accessToken, String refreshToken}) tokens =
          await generateTokens(email, userModel.id!);
      //?update refresh token in db
      userModel = await userCrud.update(UserModel.updateRefreshToken(
          email: email,
          id: userModel.id,
          refreshToken: tokens.refreshToken,
          accessToken: tokens.accessToken));
      if (userModel == null) {
        return Response.json({
          ConstsValues.kError: [ConstsValues.kNotFoundThisEmail],
          ConstsValues.kStatusCode: HttpStatus.badRequest
        }, HttpStatus.badRequest);
      } else {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.ok,
          ConstsValues.kMessage: ConstsValues.kLoginSuccessful,
          ConstsTables.kAccessToken: tokens.accessToken,
          ConstsTables.kRefreshToken: tokens.refreshToken,
          ConstsValues.kUser: {
            ConstsValues.kId: userModel.id,
            ConstsTables.kFirstName: userModel.firstName,
            ConstsTables.kLastName: userModel.lastName,
            ConstsTables.kEmail: userModel.email,
            ConstsTables.kPhone: userModel.phone,
            ConstsTables.kImagePath: userModel.imagePath,
            ConstsTables.kIsVerified: "true",
          }
        });
      }
    }
  }

  Future<Response> generateAccessTokenEndPoint(Request request) async {
    String? refreshToken =
        request.header(ConstsTables.kRefreshToken)?.toString();
    if (refreshToken == null) {
      return Response.json({
        ConstsValues.kError: [ConstsValues.kRefreshTokenIsRequired],
        ConstsValues.kStatusCode: HttpStatus.badRequest
      }, HttpStatus.badRequest);
    } else {
      UserCrud userCrud = UserCrud();
      UserModel? userModel = await userCrud.findUsingRefreshToken(
        UserModel.refreshToken(refreshToken: refreshToken),
      );
      if (userModel == null) {
        return Response.json({
          ConstsValues.kError: [ConstsValues.kNotFoundThisRefreshToken],
          ConstsValues.kStatusCode: HttpStatus.badRequest
        }, HttpStatus.badRequest);
      } else {
        return await generateNewAccessTokenAndUpdateTokenInDB(
            userModel, userCrud);
      }
    }
  }

  Future<dynamic> generateNewAccessTokenAndUpdateTokenInDB(
      UserModel userModel, UserCrud userCrud) async {
    String tokens =
        await genAccessToken(email: userModel.email!, userId: userModel.id!);
    //?update refresh token in db
    UserModel? user = await userCrud.update(UserModel.accessToken(
      accessToken: tokens,
      email: userModel.email!,
      id: userModel.id,
    ));
    if (user == null) {
      return Response.json({
        ConstsValues.kError: [ConstsValues.kNotFoundThisEmail],
        ConstsValues.kStatusCode: HttpStatus.badRequest
      }, HttpStatus.badRequest);
    } else {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.ok,
        ConstsValues.kMessage: ConstsValues.kLoginSuccessful,
        ConstsTables.kAccessToken: tokens,
        ConstsValues.kUser: {
          ConstsValues.kId: user.id,
          ConstsTables.kFirstName: user.firstName,
          ConstsTables.kLastName: user.lastName,
          ConstsTables.kEmail: user.email,
          ConstsTables.kPhone: user.phone,
          ConstsTables.kImagePath: user.imagePath,
          ConstsTables.kIsVerified: "true",
        }
      });
    }
  }

  Future<String> genAccessToken({
    required String email,
    required int userId,
  }) async {
    final jwt = JWT(
      {
        ConstsValues.kId: userId,
        ConstsValues.kEmail: email,
      },
      issuer: DotenvService.getAppName(),
    );
    return jwt.sign(
        SecretKey(DotenvService.getJwtSecret())); // Keep your secret key safe
  }
}
