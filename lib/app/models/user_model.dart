class SignupResponseModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  SignupResponseModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      message: json['message'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  String? verificationCode;
  String? accessToken;
  UserModel copyWith({
    int? id,
    String? hashPassword,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? imagePath,
    String? verificationCode,
  }) {
    return UserModel(
       isVerified: isVerified ?? isVerified,
      id: id ?? id,
      hashPassword: hashPassword ?? this.hashPassword,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imagePath: imagePath ?? this.imagePath,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }

  int? id;
  String? hashPassword;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? imagePath;
  int? isVerified;
  String? refreshToken;

  UserModel({
    required this.id,
    required this.hashPassword,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.imagePath,
    required this.verificationCode,
    this.isVerified,
    this.refreshToken,
  });
  UserModel.verfiy({
    required this.email,
    required this.verificationCode,
  });
  UserModel.isVerified(
      {required this.email, required this.isVerified, this.id});
  UserModel.updateRefreshToken({
    required this.email,
    required this.id,
    required this.refreshToken,
    this.verificationCode,
    this.accessToken,

    this.firstName,
    this.lastName,
    this.phone,
    this.imagePath,
    this.hashPassword,
    this.isVerified,
  });
  UserModel.fromID({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.imagePath,
    this.hashPassword,
    this.isVerified,
    this.refreshToken,
  });
  UserModel.fromEmail(
      {required this.email,
      this.id,
      this.firstName,
      this.lastName,
      this.phone,
      this.imagePath,
      this.hashPassword,
      this.isVerified,
      this.refreshToken,
      this.verificationCode,
      this.accessToken});
  UserModel.fromAccessToken(
      { this.email,
      this.id,
      this.firstName,
      this.lastName,
      this.phone,
      this.imagePath,
      this.hashPassword,
      this.isVerified,
      this.refreshToken,
      this.verificationCode,
     required this.accessToken});
     //?new
  UserModel.fromVerficationCode(
      { this.email,
      this.id,
      this.firstName,
      this.lastName,
      this.phone,
      this.imagePath,
      this.hashPassword,
      this.isVerified,
      this.refreshToken,
      this.accessToken,
     required this.verificationCode});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        isVerified: json['is_verified'],
        verificationCode: json['verification_code'],
        hashPassword: json['hash_password'],
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        phone: json['phone'],
        imagePath: json['image_path'].toString(),
        refreshToken: json['refresh_token'],
         );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'image_path': imagePath,
      'hash_password': hashPassword
    };
  }

  UserModel.updatePassword(
      {required this.email,
      required this.hashPassword,
      this.id,
      this.isVerified,
      this.firstName,
      this.lastName,
      this.phone,
      this.imagePath,
      this.refreshToken,
      this.verificationCode});

  UserModel.login(
      {required this.email,
      required this.hashPassword,
      this.id,
      this.isVerified,
      this.firstName,
      this.lastName,
      this.phone,
      this.imagePath,
      this.refreshToken,
      this.verificationCode});
  UserModel.refreshToken(
      {this.email,
      this.hashPassword,
      this.id,
      this.isVerified,
      this.firstName,
      this.lastName,
      this.phone,
      this.imagePath,
      required this.refreshToken,
      this.verificationCode});
  UserModel.accessToken({
    this.email,
    this.hashPassword,
    this.id,
    this.isVerified,
    this.firstName,
    this.lastName,
    this.phone,
    this.imagePath,
    required this.accessToken,
    this.refreshToken,
    this.verificationCode,
  });
}
