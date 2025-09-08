import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip/model/trip_member_location.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/repository/trip_member_location_repository.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

/// 여행 멤버 위치 목록 Provider
final tripMemberLocationProvider = FutureProvider<List<TripMemberLocation>>((
  ref,
) async {
  final tripState = ref.watch(tripProvider).valueOrNull;
  String? tripId;
  if (tripState is InProgressTripModel) {
    tripId = tripState.tripId.toString();
  }
  if (tripId == null) {
    return [];
  }
  final repo = ref.watch(tripMemberLocationRepository);
  return await repo.fetchMemberLocations(tripId: tripId);
});
