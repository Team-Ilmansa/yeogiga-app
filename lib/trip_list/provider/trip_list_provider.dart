import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import '../repository/trip_list_repository.dart';

final pastTripListProvider =
    StateNotifierProvider<PastTripListNotifier, List<TripModel?>>(
      (ref) => PastTripListNotifier(ref.read(tripListRepositoryProvider)),
    );

final upcomingTripListProvider =
    StateNotifierProvider<UpcomingTripListNotifier, List<TripModel?>>(
      (ref) => UpcomingTripListNotifier(ref.read(tripListRepositoryProvider)),
    );

final allTripListProvider =
    StateNotifierProvider<AllTripListNotifier, List<TripModel?>>(
      (ref) => AllTripListNotifier(ref.read(tripListRepositoryProvider)),
    );

final settingTripListProvider =
    StateNotifierProvider<SettingTripListNotifier, List<TripModel?>>(
      (ref) => SettingTripListNotifier(ref.read(tripListRepositoryProvider)),
    );

class PastTripListNotifier extends StateNotifier<List<TripModel?>> {
  final TripListRepository repository;

  PastTripListNotifier(this.repository) : super([]);

  Future<void> fetchAndSetPastTrips() async {
    final trips = await repository.fetchPastTripList();
    state = trips;
  }

  void clear() {
    state = [];
  }
}

class UpcomingTripListNotifier extends StateNotifier<List<TripModel?>> {
  final TripListRepository repository;

  UpcomingTripListNotifier(this.repository) : super([]);

  Future<void> fetchAndSetUpcomingTrips() async {
    final trips = await repository.fetchUpcomingTripList();
    state = trips;
  }

  void clear() {
    state = [];
  }
}

class AllTripListNotifier extends StateNotifier<List<TripModel?>> {
  final TripListRepository repository;

  AllTripListNotifier(this.repository) : super([]);

  Future<void> fetchAndSetAllTrips() async {
    final trips = await repository.fetchAllTripList();
    state = trips;
  }

  void clear() {
    state = [];
  }
}

class SettingTripListNotifier extends StateNotifier<List<TripModel?>> {
  final TripListRepository repository;

  SettingTripListNotifier(this.repository) : super([]);

  Future<void> fetchAndSetSettingTrips() async {
    final trips = await repository.fetchSettingTripList();
    state = trips;
  }

  void clear() {
    state = [];
  }
}
