import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoViewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = imagePath.startsWith('assets/')
        ? AssetImage(imagePath)
        : FileImage(File(imagePath)) as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: imageProvider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.5,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
      ),
    );
  }
}
