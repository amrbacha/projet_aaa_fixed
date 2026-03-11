import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:projet_aaa_fixed/core/services/notification_service.dart';

class PrayerTimesService {
  static const String baseUrl = 'http://api.aladhan.com/v1/timings';

  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  static Future<Map<String, String>?> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    date ??= DateTime.now();
    final formattedDate = '${date.day}-${date.month}-${date.year}';
    final url = '$baseUrl/$formattedDate?latitude=$latitude&longitude=$longitude&method=5'; 

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;
        return {
          'Fajr': timings['Fajr'],
          'Dhuhr': timings['Dhuhr'],
          'Asr': timings['Asr'],
          'Maghrib': timings['Maghrib'],
          'Isha': timings['Isha'],
        };
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
    }
    return null;
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  static Future<void> refreshAndScheduleAllPrayers() async {
    final position = await getCurrentLocation();
    if (position == null) return;

    final timings = await fetchPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (timings == null) return;

    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();

    final now = DateTime.now();
    final prayerNamesAr = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء'
    };

    timings.forEach((key, timeStr) async {
      final parts = timeStr.split(':');
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (scheduledTime.isAfter(now)) {
        await notificationService.schedulePrayerNotification(
          id: key.hashCode,
          title: 'حان وقت صلاة ${prayerNamesAr[key]}',
          body: 'أرحنا بها يا بلال.. الله أكبر الله أكبر',
          scheduledDate: scheduledTime,
        );
      }
    });
  }

  static double calculateQiblaDirection(double latitude, double longitude) {
    final lat1 = _degreeToRadian(latitude);
    final lon1 = _degreeToRadian(longitude);
    final lat2 = _degreeToRadian(_kaabaLatitude);
    final lon2 = _degreeToRadian(_kaabaLongitude);
    final double dLon = lon2 - lon1;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double bearing = math.atan2(y, x);
    bearing = _radianToDegree(bearing);
    bearing = (bearing + 360) % 360;
    return bearing;
  }

  static double _degreeToRadian(double degree) => degree * math.pi / 180;
  static double _radianToDegree(double radian) => radian * 180 / math.pi;
}
