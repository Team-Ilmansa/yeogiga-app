import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/main_trip/model/main_trip_model.dart';
import 'package:yeogiga/main_trip/repository/main_trip_repository.dart';

final mainTripFutureProvider = FutureProvider.autoDispose<MainTripModel?>((
  ref,
) async {
  final repo = ref.watch(mainTripRepositoryProvider);
  return await repo.fetchMainTrip();
});
