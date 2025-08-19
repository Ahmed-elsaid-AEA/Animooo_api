class ValidationHelper {
  static bool isVaildEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegex.hasMatch(email);
  }

  static bool isPasswordValidate(String email) {
    final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',);
    return passwordRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneNumberRegex = RegExp(r'^\d{9,12}$');
    return phoneNumberRegex.hasMatch(phoneNumber);
  }
}
