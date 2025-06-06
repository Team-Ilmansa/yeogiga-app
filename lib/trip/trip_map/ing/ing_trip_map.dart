import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

// TODO: 여행 멤버들 위치 구해오는 provider watch하기
// TODO: 여행 멤버들 위치 구해오는 provider watch하기
// TODO: 화면 내에서는 어떻게 갱신? -> 계속해서 fcm받아가며 갱신?
// TODO: 화면 내에서는 어떻게 갱신? -> 계속해서 fcm받아가며 갱신?
class IngTripMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'ingTripMap';
  const IngTripMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IngTripMapScreen> createState() => _IngTripMapScreenState();
}

class _IngTripMapScreenState extends ConsumerState<IngTripMapScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _myLocationButtonOffset = 0;

  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(_updateMyLocationButtonOffset);
      _updateMyLocationButtonOffset();
      // 지도 진입 시 모든 dayScheduleId에 대해 fetchDaySchedule 실행
      final trip = ref.read(tripProvider) as TripModel?;
      final scheduleAsync = ref.read(confirmScheduleProvider);
      final schedules = scheduleAsync?.schedules ?? [];
      if (trip != null && schedules.isNotEmpty) {
        for (final schedule in schedules) {
          ref
              .read(confirmScheduleProvider.notifier)
              .fetchDaySchedule(
                tripId: trip.tripId,
                dayScheduleId: schedule.id,
                day: schedule.day,
              );
        }
      }
    });
  }

  // 내 위치로 가기 버튼 항상 sheet 위에 두기
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

  // 지도 카메라를 마커들에 맞게 fit 시키기
  Future<void> _fitMapToPlaces(List<ConfirmedPlaceModel> places) async {
    if (mapController == null || places.isEmpty) return;
    if (places.length == 1) {
      await mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(places[0].latitude!, places[0].longitude!),
          zoom: 15,
        ),
      );
    } else {
      final lats = places.map((p) => p.latitude!).toList();
      final lngs = places.map((p) => p.longitude!).toList();
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

  // 마커 업데이트
  void _updateMapOverlays(List<ConfirmedPlaceModel> places) async {
    if (mapController == null) return;
    // Remove previous overlays
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

  // 내 위치버튼 생성
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

  // 내 위치로 이동하기
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

  // 여행에서 날짜 뽑기
  List<String> getDaysForTrip(TripBaseModel? trip) {
    if (trip is TripModel && trip.startedAt != null && trip.endedAt != null) {
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
              final scheduleAsync = ref.watch(confirmScheduleProvider);
              List<ConfirmedPlaceModel> placeList = [];
              if (scheduleAsync != null) {
                if (selectedDayIndex == 0) {
                  // 전체 보기: 마커/폴리라인을 모두 지우고 아무것도 표시하지 않음
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMapOverlays([]);
                  });
                } else {
                  final schedules = scheduleAsync.schedules;
                  final daySchedule = schedules.firstWhere(
                    (s) => s.day == selectedDayIndex,
                    orElse:
                        () => ConfirmedDayScheduleModel(
                          id: '',
                          day: selectedDayIndex,
                          places: [],
                        ),
                  );
                  placeList = daySchedule.places;
                  placeList =
                      placeList
                          .where(
                            (p) => p.latitude != null && p.longitude != null,
                          )
                          .toList();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMapOverlays(placeList);
                  });
                }
              }
              return NaverMap(
                onMapReady: (controller) {
                  setState(() {
                    mapController = controller;
                    _updateMapOverlays(placeList);
                  });
                  // Initial overlays
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
                            ); // 상태 반영 대기
                            final tripState = ref.read(tripProvider);
                            final scheduleAsync = ref.read(
                              confirmScheduleProvider,
                            );
                            final schedules = scheduleAsync?.schedules ?? [];
                            if (index == 0) {
                              // 전체 보기: 지도 전체 리셋
                              if (mapController != null) {
                                await mapController!.updateCamera(
                                  NCameraUpdate.withParams(
                                    target: NLatLng(
                                      36.5,
                                      127.5,
                                    ), // 대한민국 중심부 (예시)
                                    zoom: 7,
                                  ),
                                );
                              }
                              // 마커/폴리라인 모두 지움
                              _updateMapOverlays([]);
                            } else {
                              // Day 선택 시마다 무조건 fetch
                              if (tripState is TripModel) {
                                // schedules에서 해당 day의 id를 찾아서 넘긴다
                                final daySchedule = schedules.firstWhere(
                                  (s) => s.day == index,
                                  orElse:
                                      () => ConfirmedDayScheduleModel(
                                        id: '',
                                        day: index,
                                        places: [],
                                      ),
                                );
                                final fetched = await ref
                                    .read(confirmScheduleProvider.notifier)
                                    .fetchDaySchedule(
                                      tripId: tripState.tripId,
                                      dayScheduleId: daySchedule.id,
                                      day: index,
                                    );
                                List<ConfirmedPlaceModel> places = [];
                                if (fetched != null) {
                                  places =
                                      fetched.places
                                          .where(
                                            (p) =>
                                                p.latitude != null &&
                                                p.longitude != null,
                                          )
                                          .toList();
                                }
                                _updateMapOverlays(places);
                                await _fitMapToPlaces(places);
                              }
                            }
                          },
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final scheduleAsync = ref.watch(
                              confirmScheduleProvider,
                            );
                            final tripState = ref.watch(tripProvider);
                            if (scheduleAsync == null) {
                              final trip =
                                  tripState is TripModel ? tripState : null;
                              if (trip != null) {
                                Future.microtask(() {
                                  ref
                                      .read(confirmScheduleProvider.notifier)
                                      .fetchAll(trip.tripId);
                                });
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final schedules = scheduleAsync.schedules;
                            List<ConfirmedPlaceModel> placeList = [];
                            if (selectedDayIndex == 0) {
                              for (final day in schedules) {
                                placeList.addAll(day.places);
                              }
                            } else {
                              final daySchedule = schedules.firstWhere(
                                (s) => s.day == selectedDayIndex,
                                orElse:
                                    () => ConfirmedDayScheduleModel(
                                      id: '',
                                      day: selectedDayIndex,
                                      places: [],
                                    ),
                              );
                              placeList = daySchedule.places;
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
                                              done: false,
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
