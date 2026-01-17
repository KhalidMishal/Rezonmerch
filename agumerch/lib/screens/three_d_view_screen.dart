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
    // Premium dull grey wall color (fashion gallery style)
    const Color wallGrey = Color(0xFFDADADA);

    return Scaffold(
      backgroundColor: wallGrey,
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: wallGrey,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: ModelViewer(
          src: modelUrl,
          alt: 'A 3D model of $productName',
          ar: true,
          autoRotate: true,
          cameraControls: true,

          backgroundColor: wallGrey,
          environmentImage: 'neutral',
          exposure: 1.1,          // natural brightness
          shadowIntensity: 0.75,  // soft fashion shadows
          shadowSoftness: 0.9,
        ),
      ),
    );
  }
}
