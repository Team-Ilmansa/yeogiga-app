import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/repository/trip_repository.dart';
import 'package:yeogiga/w2m/provider/trip_w2m_provider.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';

//프로바이더 등록!!
final tripProvider = StateNotifierProvider<TripStateNotifier, TripBaseModel?>((
  ref,
) {
  final tripRepository = ref.watch(tripRepositoryProvider);

  return TripStateNotifier(tripRepository: tripRepository, ref: ref);
});

//프로바이더 구성요소!!
class TripStateNotifier extends StateNotifier<TripBaseModel?> {
  final Ref ref;
  final TripRepository tripRepository;

  TripStateNotifier({required this.tripRepository, required this.ref})
    : super(null);

  /// 포스트하고 결과 돌려받고,
  /// 결과로 여행 불러오고, 상태등록 까지
  Future<TripBaseModel> postTrip({required String title}) async {
    try {
      final postTripResponse = await tripRepository.postTrip(title: title);

      if (postTripResponse.data != null) {
        final getTripResponse = await tripRepository.getTripByTripId(
          tripId: postTripResponse.data!.tripId,
        );

        //생성하면 어차피 무조건 Setting 상태여서 바로 적용
        state = SettingTripModel(trip: getTripResponse.data!);
        return state!;
      } else {
        state = NoTripModel();
        return state!;
      }
    } on Exception catch (e) {
      return NoTripModel();
    }
  }

  /// 여행 불러오기.
  /// 여행 정보, 본인의 w2m, 여행의 w2m 불러와서 각각 상태저장
  Future<TripBaseModel> getTrip({required int tripId}) async {
    try {
      final getTripResponse = await tripRepository.getTripByTripId(
        tripId: tripId,
      );
      if (getTripResponse.data == null) {
        state = NoTripModel();
        return state!;
      }

      final tripData = getTripResponse.data!;
      switch (tripData.status) {
        case TripStatus.SETTING:
          state = SettingTripModel(trip: tripData);
          break;
        case TripStatus.PLANNED:
          state = PlannedTripModel(trip: tripData);
          break;
        case TripStatus.IN_PROGRESS:
          state = InProgressTripModel(trip: tripData);
          break;
        case TripStatus.COMPLETED:
          state = CompletedTripModel(trip: tripData);
          break;
        default:
          state = NoTripModel();
      }

      final userW2mResponse = await ref
          .read(userW2mProvider.notifier)
          .getUserW2m(tripId: tripId);
      final tripW2mResponse = await ref.read(tripW2mProvider(tripId).future);
      return state!;
    } on Exception catch (e) {
      state = NoTripModel();
      return state!;
    }
  }

  // 여행 시간 수정 및 상태 갱신
  Future<bool> updateTripTime({required DateTime start, required DateTime end}) async {
    if (state is! TripModel) return false;
    final tripId = (state as TripModel).tripId;

    final result = await tripRepository.patchTripTime(tripId: tripId, start: start, end: end);
    if (result) {
      // 성공 시 trip 정보 갱신
      await getTrip(tripId: tripId);
    }
    return result;
  }
}
