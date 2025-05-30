import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';

final confirmScheduleRepositoryProvider = Provider<ConfirmScheduleRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);

  return ConfirmScheduleRepository(baseUrl: 'https://$ip', dio: dio);
});

class ConfirmScheduleRepository {
  final String baseUrl;
  final Dio dio;

  ConfirmScheduleRepository({required this.baseUrl, required this.dio});
}
