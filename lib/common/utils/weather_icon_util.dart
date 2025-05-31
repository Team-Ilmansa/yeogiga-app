import 'package:flutter/material.dart';

/// 날씨 상태에 맞는 Material 아이콘을 반환
IconData getWeatherIcon(String weatherMain) {
  switch (weatherMain.toLowerCase()) {
    case 'clouds':
      return Icons.cloud_outlined;
    case 'thunderstorm':
      return Icons.flash_on_outlined;
    case 'rain':
      return Icons.umbrella_outlined;
    case 'drizzle':
      return Icons.grain_outlined;
    case 'snow':
      return Icons.ac_unit_outlined;
    case 'wind':
      return Icons.air_outlined;
    case 'clear':
      return Icons.wb_sunny_outlined;
    default:
      return Icons.wb_sunny_outlined;
  }
}
