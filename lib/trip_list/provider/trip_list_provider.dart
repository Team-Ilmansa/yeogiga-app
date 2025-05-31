import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import '../repository/trip_list_repository.dart';

final tripListProvider = StateNotifierProvider<TripListNotifier, List<TripModel?>>(
  (ref) => TripListNotifier(ref.read(tripListRepositoryProvider)),
);

class TripListNotifier extends StateNotifier<List<TripModel?>> {
  final TripListRepository repository;

  TripListNotifier(this.repository) : super([]);

  Future<void> fetchAndSetTrips() async {
    final trips = await repository.fetchTripList();
    state = trips;
  }

  void clear() {
    state = [];
  }
}
