import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';
import 'package:yeogiga/settlement/repository/settlement_repository.dart';

final settlementListProvider = StateNotifierProvider<
  SettlementListNotifier,
  AsyncValue<Map<String, List<SettlementModel>>>
>((ref) {
  final repo = ref.watch(settlementRepositoryProvider);
  return SettlementListNotifier(repo);
});

class SettlementListNotifier
    extends StateNotifier<AsyncValue<Map<String, List<SettlementModel>>>> {
  final SettlementRepository repo;

  SettlementListNotifier(this.repo) : super(const AsyncValue.data({}));

  /// Optimistic update를 위한 메서드 (아직 쓸데없음)
  void setOptimisticSettlementList(
    Map<String, List<SettlementModel>> settlements,
  ) {
    state = AsyncValue.data(settlements);
  }

  /// 정산 생성
  Future<Map<String, dynamic>> createSettlement({
    required int tripId,
    required String name,
    required int totalPrice,
    required String date,
    required String type,
    required List<Map<String, dynamic>> payers,
  }) async {
    state = const AsyncValue.loading();

    final result = await repo.createSettlement(
      tripId: tripId,
      name: name,
      totalPrice: totalPrice,
      date: date,
      type: type,
      payers: payers,
    );

    if (result['success'] == true) {
      await getSettlements(tripId: tripId);
    } else {
      state = AsyncValue.error(
        result['message'] ?? '정산 생성 실패',
        StackTrace.current,
      );
    }

    return result;
  }

  /// 정산 수정
  Future<Map<String, dynamic>> updateSettlement({
    required int tripId,
    required int settlementId,
    required String name,
    required int totalPrice,
    required String date,
    required String type,
    required List<Map<String, dynamic>> payers,
  }) async {
    state = const AsyncValue.loading();

    final result = await repo.updateSettlement(
      tripId: tripId,
      settlementId: settlementId,
      name: name,
      totalPrice: totalPrice,
      date: date,
      type: type,
      payers: payers,
    );

    if (result['success'] == true) {
      await getSettlements(tripId: tripId);
    } else {
      state = AsyncValue.error(
        result['message'] ?? '정산 수정 실패',
        StackTrace.current,
      );
    }

    return result;
  }

  /// 정산 삭제
  Future<Map<String, dynamic>> deleteSettlement({
    required int tripId,
    required int settlementId,
  }) async {
    state = const AsyncValue.loading();

    final result = await repo.deleteSettlement(
      tripId: tripId,
      settlementId: settlementId,
    );

    if (result['success'] == true) {
      await getSettlements(tripId: tripId);
    } else {
      state = AsyncValue.error(
        result['message'] ?? '정산 삭제 실패',
        StackTrace.current,
      );
    }

    return result;
  }

  /// 정산 내역 전체 조회
  Future<void> getSettlements({required int tripId}) async {
    state = const AsyncValue.loading();
    try {
      final result = await repo.getSettlements(tripId: tripId);
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 리스트 내 특정 정산 항목만 업데이트 (Optimistic Update용)
  void updateSettlementInList(SettlementModel updatedSettlement) {
    final currentState = state.value;
    if (currentState == null) return;

    // Map<String, List<SettlementModel>>에서 해당 settlement 찾아서 교체
    final updatedMap = currentState.map((date, settlements) {
      return MapEntry(
        date,
        settlements.map((s) {
          return s.id == updatedSettlement.id ? updatedSettlement : s;
        }).toList(),
      );
    });

    state = AsyncValue.data(updatedMap);
  }

  /// 백그라운드에서 조용히 새로고침 (로딩 상태 없이)
  Future<void> silentRefreshSettlements({required int tripId}) async {
    try {
      final result = await repo.getSettlements(tripId: tripId);
      // 로딩 상태를 거치지 않고 바로 데이터 교체 (화면 깜빡임 방지)
      state = AsyncValue.data(result);
    } catch (e) {
      // 실패해도 현재 state 유지 (에러만 로깅)
      print('[Silent Refresh Failed] $e');
      // state는 변경하지 않음
    }
  }
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ단일 정산 상태관리ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

final settlementProvider =
    StateNotifierProvider<SettlementNotifier, AsyncValue<SettlementModel?>>((
      ref,
    ) {
      final repo = ref.watch(settlementRepositoryProvider);
      return SettlementNotifier(repo, ref);
    });

class SettlementNotifier extends StateNotifier<AsyncValue<SettlementModel?>> {
  final SettlementRepository repo;
  final Ref ref;

  SettlementNotifier(this.repo, this.ref) : super(const AsyncValue.data(null));

  /// 정산 내역 단일 조회
  Future<void> getOneSettlement({
    required int tripId,
    required int settlementId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await repo.getSettlement(
        tripId: tripId,
        settlementId: settlementId,
      );
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Optimistic update를 위한 메서드
  void setOptimisticSettlement(SettlementModel settlement) {
    state = AsyncValue.data(settlement);
  }

  /// 정산 완료 여부 갱신
  Future<Map<String, dynamic>> updateSettlementCompletion({
    required int tripId,
    required int settlementId,
    required List<Map<String, dynamic>> payInfos,
  }) async {
    final result = await repo.updateSettlementCompletion(
      tripId: tripId,
      settlementId: settlementId,
      payInfos: payInfos,
    );

    // API 성공 시 settlementListProvider도 업데이트
    if (result['success'] == true) {
      final currentSettlement = state.value;
      if (currentSettlement != null) {
        // List provider도 optimistic update
        ref
            .read(settlementListProvider.notifier)
            .updateSettlementInList(currentSettlement);
      }
    }

    return result;
  }
}
