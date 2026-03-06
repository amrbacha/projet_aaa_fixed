import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_aaa/core/services/prayer_times_service.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _isAligned = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInit();
  }

  Future<void> _checkPermissionsAndInit() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      _initializeLocation();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeLocation() async {
    final position = await PrayerTimesService.getCurrentLocation();
    if (position != null && mounted) {
      final qibla = PrayerTimesService.calculateQiblaDirection(position.latitude, position.longitude);
      setState(() {
        _currentPosition = position;
        _qiblaDirection = qibla;
        _isLoading = false;
      });
    }
  }

  double _calculateDistance() {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      21.4225, // Kaaba Lat
      39.8262, // Kaaba Lon
    ) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('اتجاه القبلة', 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
          : !_hasPermission 
            ? _buildPermissionError()
            : Column(
                children: [
                  _buildInfoCard(),
                  Expanded(
                    child: Center(
                      child: _buildCompassSection(screenWidth),
                    ),
                  ),
                  _buildAccuracyStatus(),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, color: Colors.redAccent, size: 60),
          const SizedBox(height: 20),
          Text("يجب تفعيل الوصول للموقع\nلحساب اتجاه القبلة", 
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkPermissionsAndInit,
            child: const Text("تفعيل الآن"),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("المسافة إلى مكة", "${_calculateDistance().toInt()} كم"),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem("زاوية القبلة", "${_qiblaDirection?.toInt()}°"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
        Text(value, style: GoogleFonts.notoSans(color: const Color(0xFFF5A623), fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCompassSection(double screenWidth) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("خطأ في قراءة الحساسات", style: TextStyle(color: Colors.white)));
        }

        if (!snapshot.hasData || snapshot.data!.heading == null) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFF5A623)),
                SizedBox(height: 20),
                Text("جاري استشعار الحركة...", style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        double deviceHeading = snapshot.data!.heading!;
        // تأكد من تحديث القبلة إذا لم تكن موجودة
        if (_qiblaDirection == null) return const Center(child: CircularProgressIndicator());

        double diff = (_qiblaDirection! - deviceHeading + 360) % 360;
        
        bool aligned = diff < 10 || diff > 350; // جعل مجال المحاذاة أوسع قليلاً لسهولة الاستخدام
        if (aligned && !_isAligned) {
          HapticFeedback.heavyImpact();
          _isAligned = true;
        } else if (!aligned) {
          _isAligned = false;
        }

        double dialSize = screenWidth * 0.85;
        double needleSize = dialSize * 0.8;

        return Stack(
          alignment: Alignment.center,
          children: [
            // هالة ضوئية عند المحاذاة
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: aligned ? 1.0 : 0.0,
              child: Container(
                width: dialSize, height: dialSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 100, spreadRadius: 30)
                  ],
                ),
              ),
            ),
            
            // قرص البوصلة (يدور مع الهاتف)
            Transform.rotate(
              angle: (deviceHeading * (math.pi / 180) * -1),
              child: Image.asset(
                'assets/images/qibla_dial.png', 
                width: dialSize,
                errorBuilder: (c, e, s) => Container(
                  width: dialSize, height: dialSize,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                  child: const Center(child: Icon(Icons.compass_calibration, color: Colors.white24, size: 100)),
                ),
              ),
            ),

            // إبرة الكعبة (تشير دائماً لمكة)
            Transform.rotate(
              angle: (diff * (math.pi / 180)),
              child: Image.asset(
                'assets/images/qibla_needle.png', 
                height: needleSize,
                errorBuilder: (c, e, s) => Icon(Icons.navigation, color: aligned ? Colors.greenAccent : const Color(0xFFF5A623), size: 100),
              ),
            ),

            // مؤشر الدرجة في الوسط
            Positioned(
              bottom: dialSize * 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(15)),
                child: Text(aligned ? "القبلة" : "${diff.toInt()}°",
                  style: GoogleFonts.notoSans(
                    color: aligned ? Colors.greenAccent : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccuracyStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors, color: _isAligned ? Colors.green : Colors.orangeAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            _isAligned ? "القبلة مضبوطة" : "حرك الهاتف ببطء",
            style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
