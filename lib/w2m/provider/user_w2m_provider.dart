import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/user/repository/user_me_repository.dart';
import 'package:yeogiga/w2m/model/user_w2m_model.dart';
import 'package:yeogiga/w2m/repository/w2m_repository.dart';

final userW2mProvider =
    StateNotifierProvider<UserW2mStateNotifier, UserW2mBaseModel?>((ref) {
      final w2mRepository = ref.watch(w2mRepositoryProvider);

      return UserW2mStateNotifier(w2mRepository: w2mRepository);
    });

//========================================================================================
//========================================================================================

class UserW2mStateNotifier extends StateNotifier<UserW2mBaseModel?> {
  final W2mRepository w2mRepository;

  UserW2mStateNotifier({required this.w2mRepository}) : super(null);

  //유저의 w2m 불러오고, 상태 변경 및 반환
  Future<UserW2mBaseModel> getUserW2m({required int tripId}) async {
    try {
      final response = await w2mRepository.getUserW2m(tripId: tripId);

      if (response != null) {
        state = UserW2mModel(availableDates: response);
        return state!;
      } else {
        state = NoUserW2mModel();
        return state!;
      }
    } on Exception catch (e) {
      state = NoUserW2mModel();
      return state!;
    }
  }

  //유저가 w2m 등록하면 상태 변경 및 반환
  Future<UserW2mBaseModel> postUserW2m({
    required int tripId,
    required List<String> availableDates,
  }) async {
    try {
      bool response = await w2mRepository.postW2m(
        tripId: tripId,
        availableDates: availableDates,
      );

      if (response == true) {
        state = UserW2mModel(availableDates: availableDates);
        return state!;
      } else {
        state = NoUserW2mModel();
        return state!;
      }
    } on Exception catch (e) {
      //base 모델일때는 오류났나고 알려주기.
      state = UserW2mBaseModel();
      return state!;
    }
  }
}
