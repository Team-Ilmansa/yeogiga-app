import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip/model/trip_host_route_day.dart';
import 'package:yeogiga/trip/repository/trip_host_route_repository.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

/// 여행 방장 위치 전체 이력 Provider (완료된 여행에서만 사용)
final tripHostRouteProvider = FutureProvider<List<TripHostRouteDay>>((ref) async {
  final tripState = ref.watch(tripProvider);
  String? tripId;
  if (tripState is CompletedTripModel) {
    tripId = tripState.tripId.toString();
  }
  if (tripId == null) {
    return [];
  }
  final repo = ref.watch(tripHostRouteRepositoryProvider);
  return await repo.fetchHostRoutes(tripId: tripId);
});
