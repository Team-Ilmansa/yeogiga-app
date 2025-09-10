import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/provider/selection_mode_provider.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/gallery_tab.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/model/trip_host_route_day.dart';
import 'package:yeogiga/trip/provider/trip_host_route_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/view/trip_detail_screen.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';

class EndTripMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'endTripMap';
  const EndTripMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EndTripMapScreen> createState() => EndTripMapScreenState();
}

class EndTripMapScreenState extends ConsumerState<EndTripMapScreen> {
  // 갤러리탭 리프레쉬
  Future<void> refreshAll() async {
    final trip = ref.read(tripProvider).valueOrNull;
    final isCompleted = trip is CompletedTripModel;
    int tripId = (trip is TripModel) ? trip.tripId : 0;
    // invalidate 일정/이미지 provider
    ref.invalidate(pendingDayTripImagesProvider);
    ref.invalidate(unmatchedTripImagesProvider);
    ref.invalidate(matchedTripImagesProvider);
    // 일정 fetchAll
    if (isCompleted) {
      await ref.read(completedScheduleProvider.notifier).fetch(tripId);
      final completed = ref.read(completedScheduleProvider).valueOrNull;
      if (completed != null && completed.data.isNotEmpty) {
        final pendingDayPlaceInfos =
            completed.data
                .map(
                  (dayPlace) => PendingTripDayPlaceInfo(
                    day: dayPlace.day,
                    tripDayPlaceId: dayPlace.id,
                  ),
                )
                .toList();
        final unmatchedDayPlaceInfos =
            completed.data
                .map(
                  (dayPlace) => UnMatchedTripDayPlaceInfo(
                    day: dayPlace.day,
                    tripDayPlaceId: dayPlace.id,
                  ),
                )
                .toList();
        final matchedDayPlaceInfos =
            completed.data
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
            .fetchAll(tripId, pendingDayPlaceInfos);
        await ref
            .read(unmatchedTripImagesProvider.notifier)
            .fetchAll(tripId, unmatchedDayPlaceInfos);
        await ref
            .read(matchedTripImagesProvider.notifier)
            .fetchAll(tripId, matchedDayPlaceInfos);
      }
    } else {
      await ref.read(confirmScheduleProvider.notifier).fetchAll(tripId);
      final confirmed = ref.read(confirmScheduleProvider).valueOrNull;
      if (confirmed != null && confirmed.schedules.isNotEmpty) {
        final matchedDayPlaceInfos =
            confirmed.schedules
                .map(
                  (schedule) => MatchedDayPlaceInfo(
                    day: schedule.day,
                    tripDayPlaceId: schedule.id,
                    placeIds: schedule.places.map((e) => e.id).toList(),
                  ),
                )
                .toList();
        final unmatchedDayPlaceInfos =
            confirmed.schedules
                .map(
                  (schedule) => UnMatchedTripDayPlaceInfo(
                    day: schedule.day,
                    tripDayPlaceId: schedule.id,
                  ),
                )
                .toList();
        final pendingDayPlaceInfos =
            confirmed.schedules
                .map(
                  (schedule) => PendingTripDayPlaceInfo(
                    day: schedule.day,
                    tripDayPlaceId: schedule.id,
                  ),
                )
                .toList();
        await ref
            .read(matchedTripImagesProvider.notifier)
            .fetchAll(tripId, matchedDayPlaceInfos);
        await ref
            .read(unmatchedTripImagesProvider.notifier)
            .fetchAll(tripId, unmatchedDayPlaceInfos);
        await ref
            .read(pendingDayTripImagesProvider.notifier)
            .fetchAll(tripId, pendingDayPlaceInfos);
      }
    }
    setState(() {
      ref.read(selectionModeProvider.notifier).state = false;
    });
  }

  bool _allDaysFetched = false;
  bool _fetchedAndFitted = false;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int selectedDayIndex = 0;
  bool selectionMode = false;

  Map<String, List<String>> matchedOrUnmatchedPayload = {};
  Map<String, List<String>> pendingPayload = {};

  @override
  void initState() {
    super.initState();
    // CompletedSchedule 초기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllDaysAndUpdateMarkers();
      final trip = ref.read(tripProvider).valueOrNull;
      if (trip is CompletedTripModel) {
        ref.read(completedScheduleProvider.notifier).fetch(trip.tripId);
      }
    });
  }

  Future<void> _fetchAllDaysAndUpdateMarkers() async {
    final trip = ref.read(tripProvider).valueOrNull;
    if (trip is! CompletedTripModel) return;
    await ref.read(completedScheduleProvider.notifier).fetch(trip.tripId);
    // 모든 day의 데이터가 provider에 들어올 때까지 대기
    var completedAsync = ref.read(completedScheduleProvider).valueOrNull;
    var schedules = completedAsync?.data ?? [];
    if (schedules.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
      completedAsync = ref.read(completedScheduleProvider).valueOrNull;
      schedules = completedAsync?.data ?? [];
      if (schedules.isEmpty) {
        return;
      }
    }
    if (mounted) {
      setState(() {
        _allDaysFetched = true;
      });
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  NaverMapController? mapController;
  List<NMarker> _placeMarkers = [];
  NPolylineOverlay? _polyline;
  NLocationOverlay? _locationOverlay;

  Future<void> _fitMapToPlaces(List<CompletedTripPlaceModel> places) async {
    if (mapController == null || places.isEmpty) return;
    final validPlaces =
        places.where((p) => p.latitude != null && p.longitude != null).toList();
    if (validPlaces.length == 1) {
      await mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(validPlaces[0].latitude!, validPlaces[0].longitude!),
          zoom: 15,
        ),
      );
    } else {
      final lats = validPlaces.map((p) => p.latitude!).toList();
      final lngs = validPlaces.map((p) => p.longitude!).toList();
      final southWest = NLatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      );
      final northEast = NLatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      );
      final bounds = NLatLngBounds(southWest: southWest, northEast: northEast);
      await mapController!.updateCamera(
        NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(24.w)),
      );
    }
  }

  void _updateMapOverlays(
    List<CompletedTripPlaceModel> places, {
    List<NLatLng>? hostRouteCoords,
  }) async {
    if (mapController == null) return;
    await mapController!.clearOverlays();
    _placeMarkers.clear();
    _polyline = null;
    final validPlaces =
        places.where((p) => p.latitude != null && p.longitude != null).toList();
    for (final place in validPlaces) {
      final marker = NMarker(
        id: place.id,
        position: NLatLng(place.latitude!, place.longitude!),
        caption: NOverlayCaption(text: place.name),
      );
      _placeMarkers.add(marker);
      await mapController!.addOverlay(marker);
    }
    // 일정 폴리라인
    if (validPlaces.length >= 2) {
      final polyline = NPolylineOverlay(
        id: 'trip_polyline',
        coords:
            validPlaces.map((p) => NLatLng(p.latitude!, p.longitude!)).toList(),
        color: const Color(0xFF8287FF),
        width: 4.w,
      );
      _polyline = polyline;
      await mapController!.addOverlay(polyline);
    }
    // 방장 경로 폴리라인 (hostRouteCoords)
    print(hostRouteCoords);
    if (hostRouteCoords != null && hostRouteCoords.length >= 2) {
      final hostPolyline = NPolylineOverlay(
        id: 'host_route_polyline',
        coords: hostRouteCoords,
        color: const Color(0xff2ac308), // 빨간색
        width: 2.w,
      );
      await mapController!.addOverlay(hostPolyline);
    }
    // 권한 요청
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        final overlay = mapController!.getLocationOverlay();
        overlay.setIsVisible(true);
        overlay.setPosition(NLatLng(pos.latitude, pos.longitude));
        _locationOverlay = overlay;
      }
    } catch (_) {}
  }

  // TODO: 내 위치로 카메라 이동 함수
  Future<void> _moveToMyLocation() async {
    if (mapController == null) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    await mapController!.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(pos.latitude, pos.longitude),
        zoom: 15,
      ),
    );
  }

  // TODO: day 뽑아내기
  List<String> getDaysForTrip(TripBaseModel? trip) {
    if (trip is CompletedTripModel &&
        trip.startedAt != null &&
        trip.endedAt != null) {
      final start = DateTime.parse(trip.startedAt!.substring(0, 10));
      final end = DateTime.parse(trip.endedAt!.substring(0, 10));
      final dayCount = end.difference(start).inDays + 1;
      return List.generate(dayCount, (index) => 'DAY ${index + 1}');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider).valueOrNull;
    final days = getDaysForTrip(tripState);
    final hostRouteAsync = ref.watch(tripHostRouteProvider);
    return WillPopScope(
      onWillPop: () async {
        ref.read(selectionModeProvider.notifier).state = false;
        return true; // true를 리턴하면 실제로 pop이 일어남
      },
      child: Scaffold(
        bottomNavigationBar: _getPictureOptionBar(
          ref,
          selectedDayIndex,
          matchedOrUnmatchedPayload,
          pendingPayload,
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // TODO: 네이버 지도 파트
            Consumer(
              builder: (context, ref, _) {
                final completedAsync =
                    ref.watch(completedScheduleProvider).valueOrNull;
                if (completedAsync == null || completedAsync.data.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!_allDaysFetched) {
                  return const Center(child: CircularProgressIndicator());
                }
                final schedules = completedAsync.data;
                final placeList =
                    selectedDayIndex == 0
                        ? [for (final day in schedules) ...day.places]
                            .where(
                              (p) => p.latitude != null && p.longitude != null,
                            )
                            .toList()
                        : schedules
                            .firstWhere(
                              (s) => s.day == selectedDayIndex,
                              orElse:
                                  () => CompletedTripDayPlaceModel(
                                    day: selectedDayIndex,
                                    places: [],
                                    id: '',
                                    unmatchedImage: null,
                                  ),
                            )
                            .places
                            .where(
                              (p) => p.latitude != null && p.longitude != null,
                            )
                            .toList();
                // host route polyline 좌표 추출
                List<NLatLng> hostRouteCoords = [];
                if (hostRouteAsync is AsyncData<List<TripHostRouteDay>>) {
                  final hostRoutes = hostRouteAsync.value ?? [];
                  if (selectedDayIndex == 0) {
                    // 전체 여행: 모든 day의 좌표를 합침
                    hostRouteCoords = [
                      for (final day in hostRoutes)
                        ...day.routes.map(
                          (p) => NLatLng(p.latitude, p.longitude),
                        ),
                    ];
                  } else {
                    // 특정 day: 해당 day의 좌표만
                    final dayRoute = hostRoutes.firstWhere(
                      (d) => d.day == selectedDayIndex,
                      orElse:
                          () => TripHostRouteDay(
                            day: selectedDayIndex,
                            routes: [],
                          ),
                    );
                    hostRouteCoords =
                        dayRoute.routes
                            .map((p) => NLatLng(p.latitude, p.longitude))
                            .toList();
                  }
                }
                if (mapController != null && placeList.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMapOverlays(
                      placeList,
                      hostRouteCoords: hostRouteCoords,
                    );
                  });
                }
                return NaverMap(
                  onMapReady: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateMapOverlays(
                        placeList,
                        hostRouteCoords: hostRouteCoords,
                      );
                    });
                  },
                  onMapTapped: (point, latLng) {
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
            // TODO: 뒤로 가기 버튼
            Positioned(
              top: 15.h,
              left: 9.w,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectionModeProvider.notifier).state = false;
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9.w),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 17.w,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            // 내 위치로 가기 버튼
            MyLocationButton(
              controller: _sheetController,
              onTap: _moveToMyLocation,
            ),
            // TODO: 하단 슬라이더 위젯
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.215,
              minChildSize: 0.08,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return EndTripBottomSheet(
                  scrollController: scrollController,
                  days: days,
                  selectedDayIndex: selectedDayIndex,
                  onDayChanged: (index) async {
                    setState(() {
                      selectedDayIndex = index;
                    });

                    // 기존 DaySelector onChanged의 지도 마커/폴리라인 갱신 로직
                    final tripState = ref.read(tripProvider).valueOrNull;
                    if (index == 0) {
                      // 전체 보기: 지도 전체 리셋
                      final completedAsync =
                          ref.read(completedScheduleProvider).valueOrNull;
                      final schedules = completedAsync?.data ?? [];
                      final allPlaces =
                          [for (final day in schedules) ...day.places]
                              .where(
                                (p) =>
                                    p.latitude != null && p.longitude != null,
                              )
                              .toList();
                      // host route polyline 좌표 추출 (전체)
                      List<NLatLng> hostRouteCoords = [];
                      final hostRouteAsync = ref.read(tripHostRouteProvider);
                      if (hostRouteAsync is AsyncData<List<TripHostRouteDay>>) {
                        final hostRoutes = hostRouteAsync.value ?? [];
                        hostRouteCoords = [
                          for (final day in hostRoutes)
                            ...day.routes.map(
                              (p) => NLatLng(p.latitude, p.longitude),
                            ),
                        ];
                      }
                      _updateMapOverlays(
                        allPlaces,
                        hostRouteCoords: hostRouteCoords,
                      );
                      await _fitMapToPlaces(allPlaces);
                    } else {
                      final completedAsync =
                          ref.read(completedScheduleProvider).valueOrNull;
                      final schedules = completedAsync?.data ?? [];
                      final daySchedule = schedules.firstWhere(
                        (s) => s.day == index,
                        orElse:
                            () => CompletedTripDayPlaceModel(
                              day: index,
                              places: [],
                              id: '',
                              unmatchedImage: null,
                            ),
                      );
                      final places =
                          daySchedule.places
                              .where(
                                (p) =>
                                    p.latitude != null && p.longitude != null,
                              )
                              .toList();
                      // host route polyline 좌표 추출 (해당 day)
                      List<NLatLng> hostRouteCoords = [];
                      final hostRouteAsync = ref.read(tripHostRouteProvider);
                      if (hostRouteAsync is AsyncData<List<TripHostRouteDay>>) {
                        final hostRoutes = hostRouteAsync.value ?? [];
                        final dayRoute = hostRoutes.firstWhere(
                          (d) => d.day == index,
                          orElse:
                              () => TripHostRouteDay(day: index, routes: []),
                        );
                        hostRouteCoords =
                            dayRoute.routes
                                .map((p) => NLatLng(p.latitude, p.longitude))
                                .toList();
                      }
                      _updateMapOverlays(
                        places,
                        hostRouteCoords: hostRouteCoords,
                      );
                      await _fitMapToPlaces(places);
                    }
                  },
                  buildPlaceList: () {
                    final completedAsync =
                        ref.watch(completedScheduleProvider).valueOrNull;
                    final tripState = ref.watch(tripProvider).valueOrNull;

                    if (completedAsync == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final schedules = completedAsync.data;
                    List<CompletedTripPlaceModel> placeList = [];
                    if (selectedDayIndex == 0) {
                      placeList =
                          [for (final day in schedules) ...day.places]
                              .where(
                                (p) =>
                                    p.latitude != null && p.longitude != null,
                              )
                              .toList();
                    } else {
                      final daySchedule = schedules.firstWhere(
                        (s) => s.day == selectedDayIndex,
                        orElse:
                            () => CompletedTripDayPlaceModel(
                              day: selectedDayIndex,
                              places: [],
                              id: '',
                              unmatchedImage: null,
                            ),
                      );
                      placeList =
                          daySchedule.places
                              .where(
                                (p) =>
                                    p.latitude != null && p.longitude != null,
                              )
                              .toList();
                    }
                    final hasPlaces = placeList.isNotEmpty;
                    return SizedBox(
                      height: 92.h,
                      child:
                          hasPlaces
                              ? PageView.builder(
                                itemCount: placeList.length,
                                controller: PageController(
                                  viewportFraction: 0.95,
                                ),
                                itemBuilder: (context, idx) {
                                  final place = placeList[idx];
                                  return GestureDetector(
                                    onTap: () async {
                                      if (mapController != null &&
                                          place.latitude != null &&
                                          place.longitude != null) {
                                        await mapController!.updateCamera(
                                          NCameraUpdate.withParams(
                                            target: NLatLng(
                                              place.latitude!,
                                              place.longitude!,
                                            ),
                                            zoom: 15,
                                          ),
                                        );
                                      }
                                    },
                                    child: ScheduleItem(
                                      key: ValueKey(place.id),
                                      title: place.name,
                                      category: place.type,
                                      time: null,
                                      done: true,
                                    ),
                                  );
                                },
                              )
                              : Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '등록된 일정이 없습니다.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xffc6c6c6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                    );
                  },
                  onSelectionPayloadChanged: (matchedOrUnmatched, pending) {
                    setState(() {
                      matchedOrUnmatchedPayload = matchedOrUnmatched;
                      pendingPayload = pending;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyLocationButton extends StatefulWidget {
  final DraggableScrollableController controller;
  final VoidCallback onTap;

  const MyLocationButton({
    Key? key,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MyLocationButton> createState() => _MyLocationButtonState();
}

class _MyLocationButtonState extends State<MyLocationButton> {
  double _buttonOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateButtonPosition);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateButtonPosition);
    super.dispose();
  }

  void _updateButtonPosition() {
    if (mounted) {
      setState(() {
        // Button should always stay 16.h above the slider bar
        final screenHeight = MediaQuery.of(context).size.height;
        final currentSize = widget.controller.size;
        final sheetHeight = screenHeight * currentSize;

        _buttonOffset = sheetHeight + 16.h;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18.w,
      bottom: _buttonOffset, // Always 16.h above slider bar
      child: Material(
        color: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: SizedBox(
            width: 36.w,
            height: 36.w,
            child: Icon(
              Icons.my_location_outlined,
              color: Colors.black,
              size: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}

Widget? _getPictureOptionBar(
  WidgetRef ref,
  int selectedDayIndex,
  Map<String, List<String>> matchedOrUnmatchedPayload,
  Map<String, List<String>> pendingPayload,
) {
  bool selectionMode = ref.watch(selectionModeProvider);
  if (selectionMode) {
    return BottomAppBarLayout(
      child: PictureOptionState(
        selectedDayIndex: selectedDayIndex,
        matchedOrUnmatchedPayload: matchedOrUnmatchedPayload,
        pendingPayload: pendingPayload,
      ),
    );
  } else {
    return null;
  }
}

class EndTripBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> days;
  final int selectedDayIndex;
  final ValueChanged<int> onDayChanged;
  final Widget Function()? buildPlaceList;
  final Function(Map<String, List<String>>, Map<String, List<String>>)?
  onSelectionPayloadChanged;

  const EndTripBottomSheet({
    Key? key,
    required this.scrollController,
    required this.days,
    required this.selectedDayIndex,
    required this.onDayChanged,
    this.buildPlaceList,
    this.onSelectionPayloadChanged,
  }) : super(key: key);

  @override
  State<EndTripBottomSheet> createState() => _EndTripBottomSheetState();
}

class _EndTripBottomSheetState extends State<EndTripBottomSheet> {
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.selectedDayIndex;
  }

  @override
  void didUpdateWidget(covariant EndTripBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDayIndex != oldWidget.selectedDayIndex) {
      _selectedDayIndex = widget.selectedDayIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3),
        ],
      ),
      child: ListView(
        controller: widget.scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 9.h, bottom: 12.h),
                  child: Container(
                    width: 99.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffe1e1e1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
              DaySelector(
                itemCount: widget.days.length + 1,
                selectedIndex: _selectedDayIndex,
                onChanged: (index) {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                  widget.onDayChanged(index);
                },
              ),
              if (widget.buildPlaceList != null) widget.buildPlaceList!(),
              GalleryTab(
                sliverMode: false,
                showDaySelector: false,
                selectedDayIndex: _selectedDayIndex,
                onDayIndexChanged: (index) {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                  widget.onDayChanged(index);
                },
                onSelectionPayloadChanged: ({
                  required matchedOrUnmatched,
                  required pending,
                }) {
                  if (widget.onSelectionPayloadChanged != null) {
                    widget.onSelectionPayloadChanged!(
                      matchedOrUnmatched,
                      pending,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
