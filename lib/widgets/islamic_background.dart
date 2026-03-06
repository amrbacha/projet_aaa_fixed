import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_aaa/core/providers/theme_provider.dart';
import 'package:projet_aaa/models/settings_model.dart';

class IslamicBackground extends StatelessWidget {
  final Widget child;

  const IslamicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<ThemeProvider>(context).settings;

    ImageProvider backgroundImage;

    if (settings.isCustomBackground) {
      final customImageFile = File(settings.backgroundImage);
      if (customImageFile.existsSync()) {
        backgroundImage = FileImage(customImageFile);
      } else {
        backgroundImage = AssetImage(AppSettings.defaultSettings().backgroundImage);
      }
    } else {
      backgroundImage = AssetImage(settings.backgroundImage);
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: backgroundImage,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: child,
    );
  }
}
