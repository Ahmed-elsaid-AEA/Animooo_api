import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashPassword {
  static String call(String password) =>  sha256.convert(utf8.encode(password)).toString();
}