import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/bottom_app_bar_layout.dart';
import 'package:yeogiga/common/component/info_dialog.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/gallery_tab.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/trip/model/trip_host_route_day.dart';
import 'package:yeogiga/trip/provider/trip_host_route_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/common/utils/trip_utils.dart';
import 'package:yeogiga/common/utils/location_helper.dart';

class EndTripMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'endTripMap';
  const EndTripMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EndTripMapScreen> createState() => EndTripMapScreenState();
}

class EndTripMapScreenState extends ConsumerState<EndTripMapScreen> {
  // _EndTripNaverMap의 GlobalKey
  final GlobalKey<_EndTripNaverMapState> _mapKey =
      GlobalKey<_EndTripNaverMapState>();
  static const List<double> _sheetSnapPoints = [0.2, 0.4, 0.8];
  static const double _midSnapPoint = 0.8;

  // Optimistic UI: 이미지 마커 즉시 제거 (외부에서 호출 가능)
  Future<void> removeImageMarkers(List<String> imageIds) async {
    await _mapKey.currentState?.removeImageMarkers(imageIds);
  }

  void _collapseSheet() {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      _midSnapPoint,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  // 갤러리탭 리프레쉬
  Future<void> refreshAll() async {
    print('[EndTripMap refreshAll] 시작');
    if (!mounted) {
      print('[EndTripMap refreshAll] mounted=false, 종료');
      return;
    }

    final trip = ref.read(tripProvider).valueOrNull;
    final isCompleted = trip is CompletedTripModel;
    int tripId = (trip is TripModel) ? trip.tripId : 0;
    print('[EndTripMap refreshAll] tripId=$tripId, isCompleted=$isCompleted');
    // invalidate 일정/이미지 provider
    ref.invalidate(pendingDayTripImagesProvider);
    ref.invalidate(unmatchedTripImagesProvider);
    ref.invalidate(matchedTripImagesProvider);
    print('[EndTripMap refreshAll] providers invalidated');
    // 일정 fetchAll
    if (isCompleted) {
      if (!mounted) return;
      print('[EndTripMap refreshAll] completedSchedule fetch 시작');
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
        print(
          '[EndTripMap refreshAll] pendingDayPlaceInfos: ${pendingDayPlaceInfos.map((e) => 'day=${e.day}, id=${e.tripDayPlaceId}').toList()}',
        );
        await ref
            .read(pendingDayTripImagesProvider.notifier)
            .fetchAll(tripId, pendingDayPlaceInfos);
        print('[EndTripMap refreshAll] pending fetchAll 완료');
        await ref
            .read(unmatchedTripImagesProvider.notifier)
            .fetchAll(tripId, unmatchedDayPlaceInfos);
        print('[EndTripMap refreshAll] unmatched fetchAll 완료');
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
    if (mounted) {
      setState(() {
        ref.read(selectionModeProvider.notifier).state = false;
      });
    }
  }

  bool _allDaysFetched = false;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _sheetAtMax = false;

  // UI 상태만 관리 (지도 관련 상태는 _EndTripNaverMap으로 이동)
  int selectedDayIndex = 0;
  bool _isImageMode = false;
  String? _selectedPlaceId;
  final PageController _placePageController = PageController(
    viewportFraction: 0.95,
  );
  int? _lastFocusedPlaceIndex;

  Map<String, List<String>> matchedOrUnmatchedPayload = {};
  Map<String, List<String>> pendingPayload = {};

  @override
  void initState() {
    super.initState();
    // CompletedSchedule 초기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchAllDaysAndUpdateMarkers();
      final trip = ref.read(tripProvider).valueOrNull;
      if (trip is CompletedTripModel) {
        ref.read(completedScheduleProvider.notifier).fetch(trip.tripId);
      }
    });
  }

  Future<void> _fetchAllDaysAndUpdateMarkers() async {
    if (!mounted) return;

    final trip = ref.read(tripProvider).valueOrNull;
    if (trip is! CompletedTripModel) return;

    await ref.read(completedScheduleProvider.notifier).fetch(trip.tripId);
    if (!mounted) return; // await 후 체크

    // 모든 day의 데이터가 provider에 들어올 때까지 대기
    var completedAsync = ref.read(completedScheduleProvider).valueOrNull;
    var schedules = completedAsync?.data ?? [];
    if (schedules.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
      if (!mounted) return; // delay 후 체크

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
    _placePageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider).valueOrNull;
    final days = TripUtils.getDaysForTrip(tripState);

    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: WillPopScope(
        onWillPop: () async {
          // selection mode 해제
          if (ref.read(selectionModeProvider)) {
            ref.read(selectionModeProvider.notifier).state = false;
          }
          // 이미지 모드 해제
          if (_isImageMode) {
            setState(() {
              _isImageMode = false;
              _selectedPlaceId = null;
            });
          }
          return true; // true를 리턴하면 실제로 pop이 일어남
        },
        child: Scaffold(
          bottomNavigationBar: _getPictureOptionBar(ref, selectedDayIndex),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // 네이버 지도 위젯
              if (_allDaysFetched)
                _EndTripNaverMap(
                  key: _mapKey,
                  selectedDayIndex: selectedDayIndex,
                  isImageMode: _isImageMode,
                  selectedPlaceId: _selectedPlaceId,
                  onPlaceMarkerTapped: (place) {
                    setState(() {
                      _isImageMode = true;
                      _selectedPlaceId = place.id;
                    });
                    _collapseSheet();
                  },
                  onImageModeExit: () {
                    setState(() {
                      _isImageMode = false;
                      _selectedPlaceId = null;
                    });
                    _collapseSheet();
                  },
                  onMapInteraction: _collapseSheet,
                )
              else
                const Center(child: CircularProgressIndicator()),
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
              // 내 위치로 가기 버튼 (기능 비활성화)
              MyLocationButton(
                controller: _sheetController,
                onTap: () {
                  _mapKey.currentState?.moveToMyLocation();
                  _collapseSheet();
                },
              ),
              // TODO: 하단 슬라이더 위젯
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  final isMax =
                      notification.extent >= _sheetSnapPoints.last - 0.01;
                  if (_sheetAtMax != isMax) {
                    if (mounted) {
                      setState(() {
                        _sheetAtMax = isMax;
                      });
                    } else {
                      _sheetAtMax = isMax;
                    }
                  }
                  return false;
                },
                child: DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: _midSnapPoint,
                  minChildSize: _sheetSnapPoints.first,
                  maxChildSize: _sheetSnapPoints.last,
                  snap: true,
                  snapSizes: _sheetSnapPoints,
                  snapAnimationDuration: const Duration(milliseconds: 80),
                  builder: (context, scrollController) {
                    return EndTripBottomSheet(
                      scrollController: scrollController,
                      sheetController: _sheetController,
                      snapSizes: _sheetSnapPoints,
                      minChildSize: _sheetSnapPoints.first,
                      maxChildSize: _sheetSnapPoints.last,
                      days: days,
                      selectedDayIndex: selectedDayIndex,
                      focusedPlaceId: _selectedPlaceId,
                      isSheetAtMax: _sheetAtMax,
                      onDayChanged: (index) {
                        if (mounted) {
                          setState(() {
                            selectedDayIndex = index;
                            _isImageMode = false;
                            _selectedPlaceId = null;
                          });
                        }
                      },
                      buildPlaceList: () {
                        final completedAsync =
                            ref.watch(completedScheduleProvider).valueOrNull;
                        final tripState = ref.watch(tripProvider).valueOrNull;

                        if (completedAsync == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final schedules = completedAsync.data;
                        List<CompletedTripPlaceModel> placeList = [];
                        if (selectedDayIndex == 0) {
                          placeList =
                              [for (final day in schedules) ...day.places]
                                  .where(
                                    (p) =>
                                        p.latitude != null &&
                                        p.longitude != null,
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
                                        p.latitude != null &&
                                        p.longitude != null,
                                  )
                                  .toList();
                        }
                        final hasPlaces = placeList.isNotEmpty;
                        final selectedPlaceId = _selectedPlaceId;

                        if (selectedPlaceId == null) {
                          _lastFocusedPlaceIndex = null;
                        } else {
                          final targetIndex = placeList.indexWhere(
                            (place) => place.id == selectedPlaceId,
                          );
                          if (targetIndex != -1 &&
                              targetIndex != _lastFocusedPlaceIndex) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_placePageController.hasClients) return;
                              _placePageController.animateToPage(
                                targetIndex,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            });
                            _lastFocusedPlaceIndex = targetIndex;
                          }
                        }

                        return SizedBox(
                          height: 92.h,
                          child:
                              hasPlaces
                                  ? PageView.builder(
                                    itemCount: placeList.length,
                                    controller: _placePageController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, idx) {
                                      final place = placeList[idx];

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: ScheduleItem(
                                            key: ValueKey(place.id),
                                            title: place.name,
                                            category: place.type,
                                            time: null,
                                            done: true,
                                          ),
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
                        if (mounted) {
                          setState(() {
                            matchedOrUnmatchedPayload = matchedOrUnmatched;
                            pendingPayload = pending;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// _EndTripNaverMap: 독립적인 지도 위젯
// ============================================
class _EndTripNaverMap extends ConsumerStatefulWidget {
  final int selectedDayIndex;
  final bool isImageMode;
  final String? selectedPlaceId;
  final Function(CompletedTripPlaceModel) onPlaceMarkerTapped;
  final VoidCallback onImageModeExit;
  final VoidCallback onMapInteraction;

  const _EndTripNaverMap({
    Key? key,
    required this.selectedDayIndex,
    required this.isImageMode,
    required this.selectedPlaceId,
    required this.onPlaceMarkerTapped,
    required this.onImageModeExit,
    required this.onMapInteraction,
  }) : super(key: key);

  @override
  ConsumerState<_EndTripNaverMap> createState() => _EndTripNaverMapState();
}

class _EndTripNaverMapState extends ConsumerState<_EndTripNaverMap> {
  NaverMapController? mapController;
  final List<NMarker> _placeMarkers = [];
  NPolylineOverlay? _polyline;
  NLocationOverlay? _locationOverlay;
  List<NMarker> _imageMarkers = [];
  List<MatchedImage> _currentPlaceImages = [];
  int _currentDay = 1;
  String? _currentPlaceName;
  String? _currentTripDayPlaceId;
  String? _currentPlaceId;
  bool _showingNoImageDialog = false;
  ProviderSubscription<AsyncValue<List<MatchedDayTripPlaceImage>>>?
  _matchedImagesSubscription;

  @override
  void didUpdateWidget(covariant _EndTripNaverMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // selectedDayIndex가 변경되었을 때만 마커 업데이트
    if (widget.selectedDayIndex != oldWidget.selectedDayIndex &&
        !widget.isImageMode) {
      _updateMarkersForDay(widget.selectedDayIndex);
    }

    // 이미지 모드 진입/해제
    if (widget.isImageMode != oldWidget.isImageMode) {
      if (widget.isImageMode && widget.selectedPlaceId != null) {
        _showImageMarkers(widget.selectedPlaceId!);
      } else if (!widget.isImageMode) {
        _exitImageMode();
      }
    } else if (widget.isImageMode &&
        widget.selectedPlaceId != oldWidget.selectedPlaceId) {
      // 이미지 모드 중 다른 장소 선택
      if (widget.selectedPlaceId != null) {
        _showImageMarkers(widget.selectedPlaceId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      onMapReady: (controller) {
        mapController = controller;
        _updateMarkersForDay(widget.selectedDayIndex);
      },
      onMapTapped: (point, latLng) {
        FocusScope.of(context).unfocus();
        widget.onMapInteraction();
        if (widget.isImageMode) {
          widget.onImageModeExit();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _matchedImagesSubscription = ref
        .listenManual<AsyncValue<List<MatchedDayTripPlaceImage>>>(
          matchedTripImagesProvider,
          (previous, next) {
            final placeId = _currentPlaceId;
            if (!mounted || placeId == null || !widget.isImageMode) return;
            if (next is AsyncData<List<MatchedDayTripPlaceImage>>) {
              _showImageMarkers(placeId);
            }
          },
        );
  }

  @override
  void dispose() {
    _matchedImagesSubscription?.close();
    super.dispose();
  }

  // 특정 day의 마커 업데이트
  Future<void> _updateMarkersForDay(int dayIndex) async {
    if (mapController == null || !mounted) return;

    final completedAsync = ref.read(completedScheduleProvider).valueOrNull;
    if (completedAsync == null) return;

    final schedules = completedAsync.data;
    final places = _getPlacesForDay(dayIndex, schedules);

    // host route 가져오기
    final hostRouteCoords = _getHostRouteForDay(dayIndex);

    // 오버레이 업데이트
    await _updateMapOverlays(places, hostRouteCoords: hostRouteCoords);

    // 카메라 조정
    await _fitMapToPlaces(places);
  }

  Future<void> moveToMyLocation() async {
    if (mapController == null) return;
    await LocationHelper.moveCameraToUser(controller: mapController!);
  }

  // 해당 day의 장소 리스트 반환
  List<CompletedTripPlaceModel> _getPlacesForDay(
    int dayIndex,
    List<CompletedTripDayPlaceModel> schedules,
  ) {
    if (dayIndex == 0) {
      return [
        for (final day in schedules) ...day.places,
      ].where((p) => p.latitude != null && p.longitude != null).toList();
    } else {
      return schedules
          .firstWhere(
            (s) => s.day == dayIndex,
            orElse:
                () => CompletedTripDayPlaceModel(
                  day: dayIndex,
                  places: [],
                  id: '',
                  unmatchedImage: null,
                ),
          )
          .places
          .where((p) => p.latitude != null && p.longitude != null)
          .toList();
    }
  }

  // host route 좌표 가져오기
  List<NLatLng> _getHostRouteForDay(int dayIndex) {
    final hostRouteAsync = ref.read(tripHostRouteProvider);
    if (hostRouteAsync is! AsyncData<List<TripHostRouteDay>>) {
      return [];
    }

    final hostRoutes = hostRouteAsync.value ?? [];
    if (dayIndex == 0) {
      return [
        for (final day in hostRoutes)
          ...day.routes.map((p) => NLatLng(p.latitude, p.longitude)),
      ];
    } else {
      final dayRoute = hostRoutes.firstWhere(
        (d) => d.day == dayIndex,
        orElse: () => TripHostRouteDay(day: dayIndex, routes: []),
      );
      return dayRoute.routes
          .map((p) => NLatLng(p.latitude, p.longitude))
          .toList();
    }
  }

  // 지도 오버레이(마커, 폴리라인) 업데이트
  Future<void> _updateMapOverlays(
    List<CompletedTripPlaceModel> places, {
    List<NLatLng>? hostRouteCoords,
  }) async {
    if (mapController == null || !mounted) return;

    try {
      await mapController!.clearOverlays();
    } catch (e) {
      return;
    }

    if (!mounted) return;

    _placeMarkers.clear();
    _polyline = null;

    final validPlaces =
        places.where((p) => p.latitude != null && p.longitude != null).toList();

    // 장소 마커 추가
    for (final place in validPlaces) {
      if (!mounted) return;

      final marker = NMarker(
        id: place.id,
        position: NLatLng(place.latitude!, place.longitude!),
        icon: NOverlayImage.fromAssetImage('asset/icon/place.png'),
        size: Size(32.w, 32.h),
        caption: NOverlayCaption(text: place.name),
      );

      marker.setOnTapListener((tappedMarker) {
        widget.onMapInteraction();
        widget.onPlaceMarkerTapped(place);
      });

      _placeMarkers.add(marker);
      try {
        await mapController!.addOverlay(marker);
      } catch (e) {
        return;
      }
    }

    if (!mounted) return;

    // 일정 폴리라인
    if (validPlaces.length >= 2) {
      final polyline = NPolylineOverlay(
        id: 'trip_polyline',
        coords:
            validPlaces.map((p) => NLatLng(p.latitude!, p.longitude!)).toList(),
        color: const Color(0xFF8287FF),
        width: 4.w,
        lineCap: NLineCap.round,
        lineJoin: NLineJoin.round,
      );
      _polyline = polyline;
      try {
        await mapController!.addOverlay(polyline);
      } catch (e) {
        return;
      }
    }

    if (!mounted) return;

    // 방장 경로 폴리라인
    if (hostRouteCoords != null && hostRouteCoords.length >= 2) {
      final hostPolyline = NPolylineOverlay(
        id: 'host_route_polyline',
        coords: hostRouteCoords,
        color: const Color(0xff2ac308),
        width: 4.w,
        lineCap: NLineCap.round,
        lineJoin: NLineJoin.round,
      );
      try {
        await mapController!.addOverlay(hostPolyline);
      } catch (e) {
        return;
      }
    }

    // 내 위치 오버레이
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final overlay = mapController!.getLocationOverlay();
        final lastKnown = await LocationHelper.getLastKnownPositionSafe();
        if (lastKnown != null) {
          overlay.setIsVisible(true);
          overlay.setPosition(NLatLng(lastKnown.latitude, lastKnown.longitude));
          _locationOverlay = overlay;
        }
        LocationHelper.refreshPositionAsync((pos) {
          if (mapController == null) return;
          overlay.setIsVisible(true);
          overlay.setPosition(NLatLng(pos.latitude, pos.longitude));
          _locationOverlay = overlay;
        });
      }
    } catch (_) {}
  }

  // 카메라를 장소들이 모두 보이도록 조정
  Future<void> _fitMapToPlaces(List<CompletedTripPlaceModel> places) async {
    final validPlaces =
        places.where((p) => p.latitude != null && p.longitude != null).toList();
    final locations =
        validPlaces.map((p) => NLatLng(p.latitude, p.longitude)).toList();
    await _fitCameraToLocations(locations);
  }

  // 범용 카메라 조정 함수
  Future<void> _fitCameraToLocations(
    List<NLatLng> locations, {
    double padding = 70.0,
  }) async {
    if (mapController == null || locations.isEmpty) return;

    if (locations.length == 1) {
      await mapController!.updateCamera(
        NCameraUpdate.withParams(target: locations[0], zoom: 15),
      );
    } else {
      final lats = locations.map((loc) => loc.latitude).toList();
      final lngs = locations.map((loc) => loc.longitude).toList();
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
        NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(padding.w)),
      );
    }
  }

  // 이미지 마커 표시
  Future<void> _showImageMarkers(String placeId) async {
    if (mapController == null || !mounted) return;

    await mapController!.clearOverlays();

    final matchedImagesAsync = ref.read(matchedTripImagesProvider);

    matchedImagesAsync.when(
      data: (matchedDayImages) {
        for (final dayImage in matchedDayImages) {
          for (final placeImage in dayImage.placeImagesList) {
            if (placeImage?.id == placeId && placeImage != null) {
              _currentDay = dayImage.day;
              _currentPlaceName = placeImage.name;
              _currentTripDayPlaceId = dayImage.tripDayPlaceId;
              _currentPlaceId = placeImage.id;
              if (placeImage.placeImages.isEmpty) {
                _currentPlaceImages = [];
                _imageMarkers.clear();
                _showNoImageDialog();
                return;
              }
              _showImageMarkersOnMap(placeImage.placeImages);
              return;
            }
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  // 이미지를 마커로 표시
  Future<void> _showImageMarkersOnMap(List<MatchedImage> images) async {
    if (mapController == null || !mounted) return;

    _imageMarkers.clear();
    _currentPlaceImages = images;

    for (final image in images) {
      final iconWidget = Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff8287ff), width: 2),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Image.network(
            image.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 20.w),
              );
            },
          ),
        ),
      );

      final marker = NMarker(
        id: 'image_${image.id}',
        position: NLatLng(image.latitude, image.longitude),
        icon: await NOverlayImage.fromWidget(
          widget: iconWidget,
          size: Size(40.w, 40.h),
          context: context,
        ),
        size: Size(40.w, 40.h),
      );

      marker.setOnTapListener((tappedMarker) {
        widget.onMapInteraction();
        _showImageView(image);
      });

      _imageMarkers.add(marker);
      await mapController!.addOverlay(marker);
    }

    if (images.isNotEmpty) {
      await _fitMapToImages(images);
    }
  }

  // 이미지 모달 표시 → TripImageView로 네비게이션
  void _showImageView(MatchedImage image) {
    final trip = ref.read(tripProvider).valueOrNull;
    final tripId = trip is TripModel ? trip.tripId : 0;
    // Convert MatchedImage list to GalleryImage list
    final galleryImages =
        _currentPlaceImages
            .map(
              (img) => GalleryImage(
                id: img.id,
                url: img.url,
                day: _currentDay,
                type: GalleryImageType.matched,
                placeName: _currentPlaceName,
                tripDayPlaceId: _currentTripDayPlaceId,
                placeId: _currentPlaceId,
                date: img.date,
                favorite: img.favorite,
              ),
            )
            .toList();

    // Find the index of the tapped image
    final initialIndex = _currentPlaceImages.indexWhere(
      (img) => img.id == image.id,
    );

    context.push(
      '/tripImageView',
      extra: {
        'images': galleryImages,
        'initialIndex': initialIndex >= 0 ? initialIndex : 0,
        'tripId': tripId,
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _fitMapToImages(List<MatchedImage> images) async {
    final validImages =
        images
            .where((img) => img.latitude != 0.0 && img.longitude != 0.0)
            .toList();
    final locations =
        validImages.map((img) => NLatLng(img.latitude, img.longitude)).toList();
    await _fitCameraToLocations(locations);
  }

  Future<void> _showNoImageDialog() async {
    if (!mounted || _showingNoImageDialog) return;
    _showingNoImageDialog = true;
    await showDialog<bool>(
      context: context,
      builder:
          (_) => const InfoDialog(
            title: '사진이 없어요!',
            content: '선택한 목적지에는 아직 등록된 사진이 없습니다.',
            asset: 'asset/icon/no_picture.svg',
          ),
    ).whenComplete(() {
      _showingNoImageDialog = false;
    });
    if (mounted) {
      widget.onImageModeExit();
    }
  }

  // 이미지 모드 종료
  Future<void> _exitImageMode() async {
    if (!mounted || mapController == null) return;

    await mapController!.clearOverlays();

    final completedAsync = ref.read(completedScheduleProvider).valueOrNull;
    if (completedAsync == null) return;

    final schedules = completedAsync.data;
    final places = _getPlacesForDay(widget.selectedDayIndex, schedules);
    final hostRouteCoords = _getHostRouteForDay(widget.selectedDayIndex);

    await _updateMapOverlays(places, hostRouteCoords: hostRouteCoords);

    final locations =
        places.map((p) => NLatLng(p.latitude, p.longitude)).toList();
    await _fitCameraToLocations(locations, padding: 50.0);
  }

  // Optimistic UI: 이미지 마커 즉시 제거 (외부에서 호출 가능)
  Future<void> removeImageMarkers(List<String> imageIds) async {
    if (mapController == null || !mounted || !widget.isImageMode) return;

    for (final imageId in imageIds) {
      final markerToRemove =
          _imageMarkers
              .where((marker) => marker.info.id == 'image_$imageId')
              .firstOrNull;

      if (markerToRemove != null) {
        try {
          await mapController!.deleteOverlay(markerToRemove.info);
          _imageMarkers.remove(markerToRemove);
        } catch (e) {
          // 에러 무시
        }
      }
    }
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
    // 초기 위치 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateButtonPosition();
    });
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

Widget? _getPictureOptionBar(WidgetRef ref, int selectedDayIndex) {
  bool selectionMode = ref.watch(selectionModeProvider);
  if (selectionMode) {
    return BottomAppBarLayout(
      child: PictureOptionState(selectedDayIndex: selectedDayIndex),
    );
  } else {
    return null;
  }
}

class EndTripBottomSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final List<double> snapSizes;
  final double minChildSize;
  final double maxChildSize;
  final List<String> days;
  final int selectedDayIndex;
  final String? focusedPlaceId;
  final bool isSheetAtMax;
  final ValueChanged<int> onDayChanged;
  final Widget Function()? buildPlaceList;
  final Function(Map<String, List<String>>, Map<String, List<String>>)?
  onSelectionPayloadChanged;

  const EndTripBottomSheet({
    Key? key,
    required this.scrollController,
    required this.sheetController,
    required this.snapSizes,
    required this.minChildSize,
    required this.maxChildSize,
    required this.days,
    required this.selectedDayIndex,
    this.focusedPlaceId,
    this.isSheetAtMax = false,
    required this.onDayChanged,
    this.buildPlaceList,
    this.onSelectionPayloadChanged,
  }) : super(key: key);

  @override
  ConsumerState<EndTripBottomSheet> createState() => _EndTripBottomSheetState();
}

class _EndTripBottomSheetState extends ConsumerState<EndTripBottomSheet> {
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

  void _onHandleDragUpdate(DragUpdateDetails details) {
    if (!widget.sheetController.isAttached) return;
    final delta = details.primaryDelta;
    if (delta == null) return;
    final parentHeight = widget.sheetController.sizeToPixels(1);
    if (parentHeight == 0) return;
    final deltaSize = delta / parentHeight;
    final target = (widget.sheetController.size - deltaSize)
        .clamp(widget.minChildSize, widget.maxChildSize);
    widget.sheetController.jumpTo(target);
  }

  void _onHandleDragEnd(DragEndDetails details) {
    if (!widget.sheetController.isAttached) return;
    final currentSize = widget.sheetController.size;
    final target = _resolveSnapTarget(
      currentSize,
      details.primaryVelocity,
    );
    widget.sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  double _resolveSnapTarget(double currentSize, double? velocity) {
    if (widget.snapSizes.isEmpty) {
      return currentSize.clamp(widget.minChildSize, widget.maxChildSize);
    }
    if (velocity != null) {
      if (velocity < -200) {
        // Dragging up → go to next larger snap
        for (final snap in widget.snapSizes) {
          if (snap > currentSize) return snap;
        }
        return widget.snapSizes.last;
      } else if (velocity > 200) {
        // Dragging down → go to next smaller snap
        for (final snap in widget.snapSizes.reversed) {
          if (snap < currentSize) return snap;
        }
        return widget.snapSizes.first;
      }
    }
    double closest = widget.snapSizes.first;
    double minDiff = (currentSize - closest).abs();
    for (final snap in widget.snapSizes) {
      final diff = (currentSize - snap).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = snap;
      }
    }
    return closest;
  }

  @override
  Widget build(BuildContext context) {
    final placeListSection = widget.buildPlaceList?.call();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: _onHandleDragUpdate,
            onVerticalDragEnd: _onHandleDragEnd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    if (mounted) {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    }
                    widget.onDayChanged(index);
                  },
                ),
                if (placeListSection != null) placeListSection,
              ],
            ),
          ),
          Expanded(
            child: GalleryTab(
              sliverMode: false,
              showDaySelector: false,
              selectedDayIndex: _selectedDayIndex,
              focusedPlaceId: widget.focusedPlaceId,
              scrollController: widget.scrollController,
              scrollPhysics: const ClampingScrollPhysics(),
              onDayIndexChanged: (index) {
                if (mounted) {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                }
                widget.onDayChanged(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
