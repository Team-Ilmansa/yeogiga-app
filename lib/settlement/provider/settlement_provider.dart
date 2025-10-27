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

  /// Optimistic update를 위한 메서드
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
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ단일 정산 상태관리ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

final settlementProvider =
    StateNotifierProvider<SettlementNotifier, AsyncValue<SettlementModel?>>((
      ref,
    ) {
      final repo = ref.watch(settlementRepositoryProvider);
      return SettlementNotifier(repo);
    });

class SettlementNotifier extends StateNotifier<AsyncValue<SettlementModel?>> {
  final SettlementRepository repo;

  SettlementNotifier(this.repo) : super(const AsyncValue.data(null));

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

    // Optimistic UI 사용으로 성공 시 추가 fetch 불필요
    // 실패 시에는 화면에서 롤백 처리
    // But. 완료 후 미정산이 0명이 될 경우 toppanel 새로고침(딤처리, 데이터 변경 등)을 위해 필요하다고 판단
    // if (result['success'] == true) {
    //   await getOneSettlement(tripId: tripId, settlementId: settlementId);
    // }

    return result;
  }
}
