import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class EndTripMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'endTripMap';
  const EndTripMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EndTripMapScreen> createState() => _EndTripMapScreenState();
}

class _EndTripMapScreenState extends ConsumerState<EndTripMapScreen> {
  bool _allDaysFetched = false;
  bool _fetchedAndFitted = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _myLocationButtonOffset = 0;
  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllDaysAndUpdateMarkers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(_updateMyLocationButtonOffset);
      _updateMyLocationButtonOffset();
    });
  }

  Future<void> _fetchAllDaysAndUpdateMarkers() async {
    final trip = ref.read(tripProvider);
    if (trip is! CompletedTripModel) return;
    await ref.read(completedScheduleProvider.notifier).fetch(trip.tripId);
    // 모든 day의 데이터가 provider에 들어올 때까지 대기
    var completedAsync = ref.read(completedScheduleProvider);
    var schedules = completedAsync?.data ?? [];
    if (schedules.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
      completedAsync = ref.read(completedScheduleProvider);
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

  void _updateMyLocationButtonOffset() {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetExtent = _sheetController.size;
    final offset = screenHeight * sheetExtent + 40.h;
    if (offset != _myLocationButtonOffset) {
      setState(() {
        _myLocationButtonOffset = offset;
      });
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(_updateMyLocationButtonOffset);
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
        NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(80.w)),
      );
    }
  }

  void _updateMapOverlays(List<CompletedTripPlaceModel> places) async {
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
    // Draw polyline if 2 or more places
    if (validPlaces.length >= 2) {
      final polyline = NPolylineOverlay(
        id: 'trip_polyline',
        coords:
            validPlaces.map((p) => NLatLng(p.latitude!, p.longitude!)).toList(),
        color: const Color(0xFF8287FF),
        width: 12.w,
      );
      _polyline = polyline;
      await mapController!.addOverlay(polyline);
    }
    // Show user location overlay (if permission granted)
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        final overlay = await mapController!.getLocationOverlay();
        overlay.setIsVisible(true);
        overlay.setPosition(NLatLng(pos.latitude, pos.longitude));
        _locationOverlay = overlay;
      }
    } catch (_) {}
  }

  Widget _buildMyLocationButton() {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _moveToMyLocation,
        child: SizedBox(
          width: 120.w,
          height: 120.w,
          child: Icon(
            Icons.my_location_outlined,
            color: Colors.black,
            size: 60.sp,
          ),
        ),
      ),
    );
  }

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
    final tripState = ref.watch(tripProvider);
    final days = getDaysForTrip(tripState);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final completedAsync = ref.watch(completedScheduleProvider);
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
              if (mapController != null && placeList.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateMapOverlays(placeList);
                });
              }
              return NaverMap(
                onMapReady: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMapOverlays(placeList);
                  });
                },
                onMapTapped: (point, latLng) {
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
          // Custom floating back button
          Positioned(
            top: 50.h,
            left: 30.w,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 56.w,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // 내 위치로 가기 버튼
          Positioned(
            left: 50.w,
            bottom: _myLocationButtonOffset,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildMyLocationButton(),
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.215,
            minChildSize: 0.025,
            maxChildSize: 0.215,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(54.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 30.h, bottom: 40.h),
                            child: Container(
                              width: 333.w,
                              height: 18.h,
                              decoration: BoxDecoration(
                                color: const Color(0xffe1e1e1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        DaySelector(
                          itemCount: days.length + 1,
                          selectedIndex: selectedDayIndex,
                          onChanged: (index) async {
                            setState(() {
                              selectedDayIndex = index;
                            });
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            final tripState = ref.read(tripProvider);
                            if (index == 0) {
                              // 전체 보기: 지도 전체 리셋
                              final completedAsync = ref.read(
                                completedScheduleProvider,
                              );
                              final schedules = completedAsync?.data ?? [];
                              final allPlaces =
                                  [for (final day in schedules) ...day.places]
                                      .where(
                                        (p) =>
                                            p.latitude != null &&
                                            p.longitude != null,
                                      )
                                      .toList();
                              _updateMapOverlays(allPlaces);
                              await _fitMapToPlaces(allPlaces);
                            } else {
                              final completedAsync = ref.read(
                                completedScheduleProvider,
                              );
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
                                            p.latitude != null &&
                                            p.longitude != null,
                                      )
                                      .toList();
                              _updateMapOverlays(places);
                              await _fitMapToPlaces(places);
                            }
                          },
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            // 최초 fetch 완료 시점에만 마커/폴리라인/카메라 fit
                            final completedAsync = ref.watch(
                              completedScheduleProvider,
                            );
                            if (!_fetchedAndFitted && completedAsync != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final schedules = completedAsync.data;
                                List<CompletedTripPlaceModel> fitPlaces = [];
                                if (selectedDayIndex == 0) {
                                  fitPlaces =
                                      [
                                            for (final day in schedules)
                                              ...day.places,
                                          ]
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
                                  fitPlaces =
                                      daySchedule.places
                                          .where(
                                            (p) =>
                                                p.latitude != null &&
                                                p.longitude != null,
                                          )
                                          .toList();
                                }
                                if (mapController != null &&
                                    fitPlaces.isNotEmpty) {
                                  _updateMapOverlays(fitPlaces);
                                  _fitMapToPlaces(fitPlaces);
                                  setState(() {
                                    _fetchedAndFitted = true;
                                  });
                                }
                              });
                            }
                            // fetch가 끝나기 전에는 아무것도 그리지 않음 (로딩만)
                            if (completedAsync == null) {
                              final trip =
                                  tripState is CompletedTripModel
                                      ? tripState
                                      : null;
                              if (trip != null) {
                                Future.microtask(() {
                                  ref
                                      .read(completedScheduleProvider.notifier)
                                      .fetch(trip.tripId);
                                });
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            // fetch가 끝나서 데이터가 들어온 경우에만 마커/지도 위젯 렌더링
                            final schedules = completedAsync.data;
                            List<CompletedTripPlaceModel> placeList = [];
                            if (selectedDayIndex == 0) {
                              // 전체 보기: 모든 day의 place를 flatten해서 마커로 표시
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
                            return SizedBox(
                              height: 310.h,
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
                                                await mapController!
                                                    .updateCamera(
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
                                              time: null,
                                              done: true,
                                            ),
                                          );
                                        },
                                      )
                                      : Center(
                                        child: Text(
                                          '등록된 일정이 없습니다.',
                                          style: TextStyle(
                                            fontSize: 48.sp,
                                            color: const Color(0xffc6c6c6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
