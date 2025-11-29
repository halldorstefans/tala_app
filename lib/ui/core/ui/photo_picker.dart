import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatelessWidget {
  final Function(File) onPhotoPicked;

  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      //maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      onPhotoPicked(File(image.path));
    }
  }

  const PhotoPicker({super.key, required this.onPhotoPicked});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _pickPhoto,
      icon: const Icon(Icons.camera_alt),
      label: const Text('Add Photo'),
    );
  }
}
