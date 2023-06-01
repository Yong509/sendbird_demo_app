import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PickImageService {
  File? image;
  Future<File?> pickImage(ImageSource imageSource) async {
    try {
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image != null) {
        return File(image.path);
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
}
