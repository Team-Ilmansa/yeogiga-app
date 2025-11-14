import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> hasAllPermissions() async {
    return _hasAlwaysLocation();
  }

  Future<bool> requestAllPermissions() async {
    final followUp = _PermissionFollowUp();
    await _requestNotificationPermission();
    await _requestCameraPermission(followUp);
    await _requestPhotoPermission(followUp);
    final locationGranted = await _requestLocationAlwaysPermission(followUp);

    if (followUp.openLocationSettings) {
      await Geolocator.openLocationSettings();
    }
    if (followUp.openAppSettings) {
      await Geolocator.openAppSettings();
    }

    return locationGranted;
  }

  Future<bool> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<bool> _hasAlwaysLocation() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always;
  }

  Future<bool> _requestLocationAlwaysPermission(
    _PermissionFollowUp followUp,
  ) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      followUp.openAppSettings = true;
      return false;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.always) {
      followUp.openAppSettings = true;
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      followUp.openLocationSettings = true;
      return false;
    }

    return true;
  }

  Future<bool> _requestCameraPermission(_PermissionFollowUp followUp) async {
    var status = await Permission.camera.status;
    if (status.isPermanentlyDenied) {
      followUp.openAppSettings = true;
      return false;
    }
    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      followUp.openAppSettings = true;
      return false;
    }
    return status.isGranted;
  }

  Future<bool> _hasPhotoPermission() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        return true;
      }
      final photosStatus = await Permission.photos.status;
      final videosStatus = await Permission.videos.status;
      return photosStatus.isGranted && videosStatus.isGranted;
    }

    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  Future<bool> _requestPhotoPermission(_PermissionFollowUp followUp) async {
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      final videosStatus = await Permission.videos.request();

      if (photosStatus.isGranted && videosStatus.isGranted) {
        return true;
      }

      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      if (photosStatus.isPermanentlyDenied ||
          videosStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
        followUp.openAppSettings = true;
      }
      return false;
    }

    var status = await Permission.photos.status;
    if (status.isPermanentlyDenied) {
      followUp.openAppSettings = true;
      return false;
    }
    status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      followUp.openAppSettings = true;
      return false;
    }
    return status.isGranted || status.isLimited;
  }
}

class _PermissionFollowUp {
  bool openAppSettings = false;
  bool openLocationSettings = false;
}
