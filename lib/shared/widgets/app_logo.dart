import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sageGreen,
        borderRadius: BorderRadius.circular(size * 0.30),
      ),
      child: Icon(Icons.layers_rounded, color: Colors.white, size: size * 0.53),
    );
  }
}
