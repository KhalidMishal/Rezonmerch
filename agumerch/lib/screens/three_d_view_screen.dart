import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ThreeDViewScreen extends StatelessWidget {
  const ThreeDViewScreen({
    super.key,
    required this.productName,
    required this.modelUrl,
  });

  final String productName;
  final String modelUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ModelViewer(
        src: modelUrl,
        alt: 'A 3D model of $productName',
        ar: true,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
