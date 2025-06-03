import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';
import 'package:yeogiga/naver/repository/naver_place_search_repository.dart';

final naverPlaceSearchProvider =
    AutoDisposeFutureProvider.family<NaverPlaceSearchResponse, String>((
      ref,
      query,
    ) async {
      final repo = ref.watch(naverPlaceSearchRepository);
      // .env에서 클라이언트 ID/Secret 자동 주입
      return await repo.searchPlaces(query: query);
    });
