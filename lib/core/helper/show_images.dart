import 'dart:io';

import 'package:animooo_api/core/consts.dart';
import 'package:vania/vania.dart';

class ShowImages {
  static Future<Response> call(String fileName) async {
    final filePath = '${ConstsValues.kImageFolderName}/$fileName';
    final file = File(filePath);
    if (!await file.exists()) {
      return Response.json(
        {
          ConstsValues.kStatusCode: HttpStatus.notFound,
          ConstsValues.kError: ConstsValues.kFileNotFound
        },
        HttpStatus.notFound,
      );
    } else {
      final bytes = await file.readAsBytes();
      return Response.file(
        filePath,
        bytes,
      );
    }
  }
}
