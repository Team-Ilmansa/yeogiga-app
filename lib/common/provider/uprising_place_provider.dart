import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/model/uprising_place_model.dart';
import 'package:yeogiga/common/repository/uprising_place_repository.dart';

final uprisingPlaceProvider = StateNotifierProvider<
    UprisingPlaceNotifier,
    AsyncValue<List<UprisingPlaceModel>>
>((ref) {
  final repo = ref.watch(uprisingPlaceRepositoryProvider);
  return UprisingPlaceNotifier(repo);
});

class UprisingPlaceNotifier extends StateNotifier<AsyncValue<List<UprisingPlaceModel>>> {
  final UprisingPlaceRepository repo;

  UprisingPlaceNotifier(this.repo) : super(const AsyncValue.data([]));

  /// 급상승 여행지 목록 조회
  Future<void> fetchUprisingPlaces() async {
    state = const AsyncValue.loading();
    try {
      final response = await repo.getUprisingPlaces();
      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 상태 초기화
  void clear() {
    state = const AsyncValue.data([]);
  }
}
