import 'package:geolocator/geolocator.dart';

class LocationUtils {
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permissions are denied
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied.
      return null;
    }

    // When permissions are granted, get current position
    return await Geolocator.getCurrentPosition();
  }
}
