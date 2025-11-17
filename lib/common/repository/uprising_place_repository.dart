import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/common/model/uprising_place_model.dart';

part 'uprising_place_repository.g.dart';

final uprisingPlaceRepositoryProvider = Provider<UprisingPlaceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UprisingPlaceRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UprisingPlaceRepository {
  factory UprisingPlaceRepository(Dio dio, {String baseUrl}) =
      _UprisingPlaceRepository;

  @GET('/uprising-places')
  @Headers({'accessToken': 'true'})
  Future<UprisingPlaceResponse> getUprisingPlaces();
}
