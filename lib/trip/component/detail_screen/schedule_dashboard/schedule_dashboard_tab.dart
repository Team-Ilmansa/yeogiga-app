import 'package:flutter/material.dart' hide ExpansionPanel;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';


import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/view/no_schedule_view.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/view/pending_schedule_view.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/view/confirmed_schedule_view.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';


class ScheduleDashboardTab extends ConsumerStatefulWidget {
  const ScheduleDashboardTab({super.key});

  @override
  ConsumerState<ScheduleDashboardTab> createState() =>
      _ScheduleDashboardTabState();
}

class _ScheduleDashboardTabState extends ConsumerState<ScheduleDashboardTab> {
  bool _pendingFetched = false;
  bool _confirmedFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tripState = ref.read(tripProvider);
    if (tripState is SettingTripModel &&
        tripState.startedAt != null &&
        tripState.endedAt != null &&
        !_pendingFetched) {
      final dynamicDays = getDaysForTrip(tripState);
      final tripId = tripState.tripId;
      final days = List.generate(dynamicDays.length, (i) => i + 1);
      Future.microtask(() {
        ref
            .read(pendingScheduleProvider.notifier)
            .fetchAll(tripId.toString(), days);
      });
      _pendingFetched = true;
    } else if ((tripState is PlannedTripModel ||
            tripState is InProgressTripModel ||
            tripState is CompletedTripModel) &&
        !_confirmedFetched) {
      final tripId = (tripState as TripModel).tripId;
      Future.microtask(() {
        ref.read(confirmScheduleProvider.notifier).fetchAll(tripId);
      });
      _confirmedFetched = true;
    }
  }

  List<String> getDaysForTrip(TripBaseModel? trip) {
    if (trip is TripModel && trip.startedAt != null && trip.endedAt != null) {
      final start = DateTime.parse(trip.startedAt!.substring(0, 10));
      final end = DateTime.parse(trip.endedAt!.substring(0, 10));
      final dayCount = end.difference(start).inDays + 1;
      return List.generate(dayCount, (index) => 'Day ${index + 1}');
    }
    return [];
  }

  int selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);
    if (tripState is SettingTripModel &&
        (tripState.startedAt == null || tripState.endedAt == null)) {
      return const NoScheduleView();
    } else if (tripState is SettingTripModel &&
        tripState.startedAt != null &&
        tripState.endedAt != null) {
      final dynamicDays = getDaysForTrip(tripState);
      return PendingScheduleView(
        dynamicDays: dynamicDays,
        selectedDayIndex: selectedDayIndex,
        onDaySelected: (index) {
          setState(() {
            selectedDayIndex = index;
          });
        },
      );
    } else if (tripState is PlannedTripModel ||
        tripState is InProgressTripModel ||
        tripState is CompletedTripModel) {
      final dynamicDays = getDaysForTrip(tripState);
      return ConfirmedScheduleView(
        dynamicDays: dynamicDays,
        selectedDayIndex: selectedDayIndex,
        onDaySelected: (index) {
          setState(() {
            selectedDayIndex = index;
          });
        },
      );
    }
    // fallback: 아무 조건에도 해당하지 않으면 빈 위젯 반환
    return const SizedBox.shrink();
  }
}
