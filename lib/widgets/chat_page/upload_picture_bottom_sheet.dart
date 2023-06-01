import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_demo_app/services/pick_image_service.dart';

class UploadPictureBottomSheet {
  final BuildContext context;
  const UploadPictureBottomSheet({required this.context});

  Future<File?> showUploadBottomSheet() async {
    late final File? image;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Upload pictures'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Take a picture'),
            onPressed: () async {
              image = await PickImageService().pickImage(ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Choose from gallery'),
            onPressed: () async {
              image = await PickImageService().pickImage(ImageSource.gallery);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
    return image;
  }
}
