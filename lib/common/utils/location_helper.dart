import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getLastKnownPositionSafe() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  static Future<Position?> getFreshPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );
    } catch (_) {
      return null;
    }
  }

  static bool isStale(
    Position position, {
    Duration staleThreshold = const Duration(minutes: 5),
  }) {
    final timestamp = position.timestamp;
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) > staleThreshold;
  }

  static Future<Position?> getBestPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration staleThreshold = const Duration(minutes: 5),
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final lastKnown = await getLastKnownPositionSafe();
    if (lastKnown != null &&
        !isStale(lastKnown, staleThreshold: staleThreshold)) {
      return lastKnown;
    }
    final fresh = await getFreshPosition(accuracy: accuracy, timeout: timeout);
    return fresh ?? lastKnown;
  }

  static Future<void> refreshPositionAsync(
    void Function(Position position) onPosition, {
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    unawaited(
      getFreshPosition(accuracy: accuracy, timeout: timeout).then((pos) {
        if (pos != null) {
          onPosition(pos);
        }
      }),
    );
  }

  static Future<bool> moveCameraToUser({
    required NaverMapController controller,
    double zoom = 15,
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration staleThreshold = const Duration(minutes: 5),
    Duration timeout = const Duration(seconds: 6),
    bool animateInitial = false,
  }) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return false;
    }

    final position = await getBestPosition(
      accuracy: accuracy,
      staleThreshold: staleThreshold,
      timeout: timeout,
    );

    if (position != null) {
      await controller.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(position.latitude, position.longitude),
          zoom: zoom,
        ),
      );
    }

    refreshPositionAsync(
      (pos) {
        controller.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(pos.latitude, pos.longitude),
            zoom: zoom,
          ),
        );
      },
      accuracy: accuracy,
      timeout: timeout,
    );

    return position != null;
  }
}
