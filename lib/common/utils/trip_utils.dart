import 'package:yeogiga/trip/model/trip_model.dart';

/// 여행 관련 유틸리티 함수들
class TripUtils {
  /// 여행 기간에 따른 일차 리스트 생성
  /// 반환: ['Day 1', 'Day 2', ...] 형태의 리스트
  static List<String> getDaysForTrip(TripBaseModel? trip) {
    if (trip is TripModel && trip.startedAt != null && trip.endedAt != null) {
      final start = DateTime.parse(trip.startedAt!.substring(0, 10));
      final end = DateTime.parse(trip.endedAt!.substring(0, 10));
      final dayCount = end.difference(start).inDays + 1;
      return List.generate(dayCount, (index) => 'Day ${index + 1}');
    }
    return [];
  }

  /// 여행 일차 개수 반환
  static int getDayCount(TripBaseModel? trip) {
    return getDaysForTrip(trip).length;
  }
}
