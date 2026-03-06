import 'package:flutter/material.dart';
import 'package:projet_aaa/core/services/local_storage_service.dart';

class ThemedScaffold extends StatefulWidget {
  final Widget child;
  const ThemedScaffold({super.key, required this.child});

  @override
  State<ThemedScaffold> createState() => _ThemedScaffoldState();
}

class _ThemedScaffoldState extends State<ThemedScaffold> {
  String? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadThemeAssets();
  }

  Future<void> _loadThemeAssets() async {
    final user = await LocalStorageService.getUserData();
    final gender = user['gender'] ?? 'male';
    
    // Simple logic to choose a background based on gender
    setState(() {
      if (gender == 'female') {
        _backgroundImage = 'assets/images/backgrounds/female_bg.png';
      } else {
        _backgroundImage = 'assets/images/backgrounds/male_bg.png';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _backgroundImage == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _backgroundImage!,
                    fit: BoxFit.cover,
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                    colorBlendMode: BlendMode.dstATop,
                  ),
                ),
                Positioned.fill(
                  child: widget.child,
                ),
              ],
            ),
    );
  }
}
