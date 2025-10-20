import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/settlement/model/settlement_day_list_model.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SettlementRepository(baseUrl: 'https://$ip', dio: dio);
});

class SettlementRepository {
  final String baseUrl;
  final Dio dio;

  SettlementRepository({required this.baseUrl, required this.dio});

  /// 정산 생성
  Future<Map<String, dynamic>> createSettlement({
    required int tripId,
    required String name,
    required int totalPrice,
    required String date,
    required String type,
    required List<Map<String, dynamic>> payers,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip/$tripId/settlements',
        data: {
          'name': name,
          'totalPrice': totalPrice,
          'date': date,
          'type': type,
          'payers': payers,
        },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': '정산 내역이 성공적으로 생성되었습니다.'};
      }
      return {'success': false, 'message': '정산 생성에 실패했습니다.'};
    } catch (e) {
      return _handleError(e, defaultMessage: '정산 생성에 실패했습니다.');
    }
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
    try {
      final response = await dio.put(
        '$baseUrl/api/v1/trip/$tripId/settlements/$settlementId',
        data: {
          'name': name,
          'totalPrice': totalPrice,
          'date': date,
          'type': type,
          'payers': payers,
        },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '정산 내역이 성공적으로 수정되었습니다.'};
      }
      return {'success': false, 'message': '정산 수정에 실패했습니다.'};
    } catch (e) {
      return _handleError(e, defaultMessage: '정산 수정에 실패했습니다.');
    }
  }

  /// 정산 삭제
  Future<Map<String, dynamic>> deleteSettlement({
    required int tripId,
    required int settlementId,
  }) async {
    try {
      final response = await dio.delete(
        '$baseUrl/api/v1/trip/$tripId/settlements/$settlementId',
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '정산 내역이 삭제되었습니다.'};
      }
      return {'success': false, 'message': '정산 삭제에 실패했습니다.'};
    } catch (e) {
      return _handleError(e, defaultMessage: '정산 삭제에 실패했습니다.');
    }
  }

  /// 정산 내역 전체 조회
  Future<Map<String, List<SettlementModel>>> getSettlements({
    required int tripId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/settlements',
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final result = SettlementDayListModel.fromJson(data);
        return result.data;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 정산 내역 단일 조회
  Future<SettlementModel> getSettlement({
    required int tripId,
    required int settlementId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/settlements/$settlementId',
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final result = SettlementModel.fromJson(data);
        return result;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 정산 완료 여부 갱신
  Future<Map<String, dynamic>> updateSettlementCompletion({
    required int tripId,
    required int settlementId,
    required List<Map<String, dynamic>> payInfos,
  }) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/v1/trip/$tripId/settlements/$settlementId',
        data: {
          'payInfos': payInfos,
        },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '정산 완료 여부가 갱신되었습니다.'};
      }
      return {'success': false, 'message': '정산 완료 여부 갱신에 실패했습니다.'};
    } catch (e) {
      return _handleError(e, defaultMessage: '정산 완료 여부 갱신에 실패했습니다.');
    }
  }

  /// 에러 처리
  Map<String, dynamic> _handleError(
    dynamic e, {
    required String defaultMessage,
  }) {
    if (e is! DioException || e.response == null) {
      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }

    final data = e.response!.data;
    final code = data['code']?.toString() ?? '';

    // 에러 코드별 메시지
    const errorMessages = {
      'S000': '정산 내역 금액 총합이 일치하지 않습니다.',
      'S001': '존재하지 않는 정산 내역 입니다.',
      'S002': '정산자가 아닙니다.',
      'S003': '존재하지 않는 분담 내역입니다.',
      'T102': '해당 여행의 멤버가 아닙니다.',
      'T105': '여행 멤버가 아닌 사용자가 존재합니다.',
      'T006': '해당 여행이 존재하지 않습니다.',
    };

    // G002: 입력값 검증 오류 (여러 필드)
    if (code == 'G002') {
      final errors = data['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        return {'success': false, 'message': errors.values.join('\n')};
      }
    }

    // 매핑된 메시지 또는 서버 메시지
    return {
      'success': false,
      'message':
          errorMessages[code] ?? data['message']?.toString() ?? defaultMessage,
    };
  }
}
