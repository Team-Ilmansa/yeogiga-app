import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/notice/model/ping_model.dart';
import '../repository/ping_repository.dart';

final pingProvider =
    StateNotifierProvider<PingNotifier, PingModel?>(
      (ref) => PingNotifier(ref.read(pingRepositoryProvider)),
    );

class PingNotifier extends StateNotifier<PingModel?> {
  final PingRepository repository;

  PingNotifier(this.repository) : super(null);

  // 집결지 조회 및 상태 업데이트
  Future<Map<String, dynamic>> fetchPing({required int tripId}) async {
    final result = await repository.fetchPing(tripId: tripId);

    if (result['success']) {
      final pingData = result['ping'];
      
      if (pingData != null) {
        // 집결지가 존재하는 경우 PingModel로 변환
        state = PingModel(
          place: pingData['place'],
          latitude: pingData['latitude'],
          longitude: pingData['longitude'],
          time: DateTime.parse(pingData['time']),
        );
      } else {
        // 집결지가 없는 경우
        state = null;
      }
    }

    return result;
  }

  // 집결지 생성
  Future<Map<String, dynamic>> createPing({
    required int tripId,
    required String place,
    required double latitude,
    required double longitude,
    required DateTime time,
  }) async {
    final result = await repository.createPing(
      tripId: tripId,
      place: place,
      latitude: latitude,
      longitude: longitude,
      time: time,
    );
    
    // 성공 시 최신 집결지 정보를 가져와서 상태 업데이트
    if (result['success']) {
      await fetchPing(tripId: tripId);
    }
    
    return result;
  }

  // 집결지 삭제
  Future<Map<String, dynamic>> deletePing({required int tripId}) async {
    // Optimistic update: 먼저 상태를 null로 변경
    final previousState = state;
    state = null;
    
    final result = await repository.deletePing(tripId: tripId);
    
    // 실패했으면 원래 상태로 되돌리기
    if (!result['success']) {
      state = previousState;
    }
    
    return result;
  }
}
