import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';

final naverPlaceSearchRepository = Provider<NaverPlaceSearchRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return NaverPlaceSearchRepository(dio: dio);
});

class NaverPlaceSearchRepository {
  final Dio dio;

  NaverPlaceSearchRepository({required this.dio});

  Future<NaverPlaceSearchResponse> searchPlaces({
    required String query,
    int display = 5,
    int start = 1,
    String sort = 'random',
  }) async {
    final response = await dio.get(
      'https://openapi.naver.com/v1/search/local.json',
      queryParameters: {
        'query': query,
        'display': display,
        'start': start,
        'sort': sort,
      },
      options: Options(
        headers: {
          'X-Naver-Client-Id': dotenv.get('NAVER_PLACE_SEARCH_CLIENT_ID'),
          'X-Naver-Client-Secret': dotenv.get(
            'NAVER_PLACE_SEARCH_CLIENT_SECRET',
          ),
        },
      ),
    );
    return NaverPlaceSearchResponse.fromJson(response.data);
  }
}
