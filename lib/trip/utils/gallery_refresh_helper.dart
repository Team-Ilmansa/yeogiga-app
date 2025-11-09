import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';

class GalleryRefreshHelper {
  const GalleryRefreshHelper._();

  static Future<void> refreshAll(WidgetRef ref) async {
    final trip = ref.read(tripProvider).valueOrNull;
    if (trip is! TripModel) return;

    final tripId = trip.tripId;
    final isCompleted = trip is CompletedTripModel;

    if (isCompleted) {
      await ref.read(completedScheduleProvider.notifier).fetch(tripId);
      final completed = ref.read(completedScheduleProvider).valueOrNull;
      if (completed == null || completed.data.isEmpty) return;

      final pendingInfos = completed.data
          .map(
            (dayPlace) => PendingTripDayPlaceInfo(
              day: dayPlace.day,
              tripDayPlaceId: dayPlace.id,
            ),
          )
          .toList();
      final unmatchedInfos = completed.data
          .map(
            (dayPlace) => UnMatchedTripDayPlaceInfo(
              day: dayPlace.day,
              tripDayPlaceId: dayPlace.id,
            ),
          )
          .toList();
      final matchedInfos = completed.data
          .map(
            (dayPlace) => MatchedDayPlaceInfo(
              day: dayPlace.day,
              tripDayPlaceId: dayPlace.id,
              placeIds: dayPlace.places.map((e) => e.id).toList(),
            ),
          )
          .toList();

      await ref
          .read(pendingDayTripImagesProvider.notifier)
          .fetchAll(tripId, pendingInfos);
      await ref
          .read(unmatchedTripImagesProvider.notifier)
          .fetchAll(tripId, unmatchedInfos);
      await ref
          .read(matchedTripImagesProvider.notifier)
          .fetchAll(tripId, matchedInfos);
    } else {
      await ref.read(confirmScheduleProvider.notifier).fetchAll(tripId);
      final confirmed = ref.read(confirmScheduleProvider).valueOrNull;
      if (confirmed == null || confirmed.schedules.isEmpty) return;

      final matchedInfos = confirmed.schedules
          .map(
            (schedule) => MatchedDayPlaceInfo(
              day: schedule.day,
              tripDayPlaceId: schedule.id,
              placeIds: schedule.places.map((e) => e.id).toList(),
            ),
          )
          .toList();
      final unmatchedInfos = confirmed.schedules
          .map(
            (schedule) => UnMatchedTripDayPlaceInfo(
              day: schedule.day,
              tripDayPlaceId: schedule.id,
            ),
          )
          .toList();
      final pendingInfos = confirmed.schedules
          .map(
            (schedule) => PendingTripDayPlaceInfo(
              day: schedule.day,
              tripDayPlaceId: schedule.id,
            ),
          )
          .toList();

      await ref
          .read(matchedTripImagesProvider.notifier)
          .fetchAll(tripId, matchedInfos);
      await ref
          .read(unmatchedTripImagesProvider.notifier)
          .fetchAll(tripId, unmatchedInfos);
      await ref
          .read(pendingDayTripImagesProvider.notifier)
          .fetchAll(tripId, pendingInfos);
    }
  }
}
