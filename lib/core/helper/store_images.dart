import 'dart:io';

import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/dotenv_service.dart';
import 'package:vania/vania.dart';
import 'package:path/path.dart' as path;

class StoreImages {
  static Future<String> call(RequestFile imageFile) async {
    String pathFolder =
        '${Directory.current.path}/${ConstsValues.kImageFolderName}';
    //?check if file same name
    if (await File(pathFolder).exists()) {
      //delete file
      await File(pathFolder).delete();
    } else {
      Directory dir = Directory(pathFolder);
      //?check if folder uploads exist
      if (!await dir.exists()) {
        //create this folder
        await dir.create(recursive: true);
      }
    }
    final ext = path.extension(imageFile.filename);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    print(fileName);
    await File('${ConstsValues.kImageFolderName}/$fileName')
        .writeAsBytes((await imageFile.bytes).toList());
    return '${DotenvService.getAppUrl()}/${ConstsValues.kApiName}/${ConstsValues.kImageFolderName}/$fileName';
  }

  static Future<bool> remove(String imageFile) async {
    try {
      String filePath = extractWithRegex(imageFile);
      await File(filePath).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

String extractWithRegex(String url) {
  final regex = RegExp(r'\/api\/(uploads\/[^\/]+\.\w+)$');
  final match = regex.firstMatch(url);
  if (match != null) {
    return match.group(1)!; // "uploads/1749550549436.png"
  }
  throw Exception("URL pattern not matched");
}
