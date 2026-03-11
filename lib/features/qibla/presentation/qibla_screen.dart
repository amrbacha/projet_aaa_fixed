import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/prayer_times_service.dart';
import '../../../widgets/islamic_background.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.qiblaDirection, 
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
            ? _buildPermissionError(l10n)
            : Column(
                children: [
                  _buildInfoCard(l10n),
                  Expanded(
                    child: Center(
                      child: _buildCompassSection(screenWidth, l10n),
                    ),
                  ),
                  _buildAccuracyStatus(l10n),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Widget _buildPermissionError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, color: Colors.redAccent, size: 60),
          const SizedBox(height: 20),
          Text(l10n.locationUpdateError, 
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkPermissionsAndInit,
            child: Text(l10n.updateNow),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations l10n) {
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
          _buildStatItem(l10n.locationService, "${_calculateDistance().toInt()} km"),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(l10n.qiblaDirection, "${_qiblaDirection?.toInt()}°"),
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

  Widget _buildCompassSection(double screenWidth, AppLocalizations l10n) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(l10n.locationUpdateError, style: const TextStyle(color: Colors.white)));
        }

        if (!snapshot.hasData || snapshot.data!.heading == null) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFF5A623)),
                SizedBox(height: 20),
                Text("...", style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        double deviceHeading = snapshot.data!.heading!;
        if (_qiblaDirection == null) return const Center(child: CircularProgressIndicator());

        double diff = (_qiblaDirection! - deviceHeading + 360) % 360;
        
        bool aligned = diff < 10 || diff > 350;
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

            Transform.rotate(
              angle: (diff * (math.pi / 180)),
              child: Image.asset(
                'assets/images/qibla_needle.png', 
                height: needleSize,
                errorBuilder: (c, e, s) => Icon(Icons.navigation, color: aligned ? Colors.greenAccent : const Color(0xFFF5A623), size: 100),
              ),
            ),

            Positioned(
              bottom: dialSize * 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(15)),
                child: Text(aligned ? l10n.qiblaDirection : "${diff.toInt()}°",
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

  Widget _buildAccuracyStatus(AppLocalizations l10n) {
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
            _isAligned ? l10n.saveSuccess : "...", // سيتم استكمال نصوص الحالة
            style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
