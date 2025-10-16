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

  /// 정산 생성
  Future<Map<String, dynamic>> createSettlement({
    required int tripId,
    required String name,
    required int totalPrice,
    required String date,
    required String type,
    required List<Map<String, dynamic>> payers,
  }) async {
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
    }

    return result;
  }

  /// 정산 삭제
  Future<Map<String, dynamic>> deleteSettlement({
    required int tripId,
    required int settlementId,
  }) async {
    final result = await repo.deleteSettlement(
      tripId: tripId,
      settlementId: settlementId,
    );

    if (result['success'] == true) {
      await getSettlements(tripId: tripId);
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
}
