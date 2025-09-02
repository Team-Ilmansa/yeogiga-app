import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/w2m/repository/w2m_repository.dart';

class TripW2mModel {
  final List<Map<String, dynamic>> availabilities;
  TripW2mModel({required this.availabilities});
}

//watch 하는 순간 로직 돌아가면서 w2m 담김.
final tripW2mProvider = AutoDisposeFutureProvider.family<TripW2mModel?, int>((
  ref,
  tripId,
) async {
  final repo = ref.watch(w2mRepositoryProvider);
  final data = await repo.getTripW2m(tripId: tripId);
  if (data != null) {
    return TripW2mModel(availabilities: data);
  }
  return null;
});
