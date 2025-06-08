import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

import 'package:yeogiga/trip/provider/trip_member_location_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/trip/model/trip_member_location.dart';
import 'package:yeogiga/user/model/user_model.dart';

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
  bool _cameraFitted = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _myLocationButtonOffset = 0;

  int selectedDayIndex = 0;

  // 지도/데이터 동기화용 플래그와 임시 변수

  bool _allDaysFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchAllDaysAndUpdateMarkers();
    // sheetController 리스너 및 위치 버튼 오프셋 갱신만 등록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(_updateMyLocationButtonOffset);
      _updateMyLocationButtonOffset();
    });
  }

  Future<void> _fetchAllDaysAndUpdateMarkers() async {
    final trip = ref.read(tripProvider) as TripModel;
    // 지도에서는 fetchAll(tripId) 호출하지 않음! 이미 state에 들어온 schedules만 사용
    var scheduleAsync = ref.read(confirmScheduleProvider);
    var schedules = scheduleAsync?.schedules ?? [];

    // schedules가 비어있으면 그냥 리턴 (혹시나 state 반영이 늦을 때는 잠깐 기다렸다가 한 번 더 시도)
    if (schedules.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
      scheduleAsync = ref.read(confirmScheduleProvider);
      schedules = scheduleAsync?.schedules ?? [];
      if (schedules.isEmpty) {
        // 한 번 더 시도 (재귀, 무한루프 방지)
        return;
      }
    }

    // day별 places만 fetch
    for (final schedule in schedules) {
      await ref
          .read(confirmScheduleProvider.notifier)
          .fetchDaySchedule(
            tripId: trip.tripId,
            dayScheduleId: schedule.id,
            day: schedule.day,
          );
    }
    if (mounted) {
      setState(() {
        _allDaysFetched = true;
      });
    }
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
  List<NMarker> _memberMarkers = [];
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
  void _updateMapOverlays(
    List<ConfirmedPlaceModel> places, {
    List<TripMemberLocation>? memberLocations,
    String? myNickname,
  }) async {
    if (mapController == null) return;
    // Remove previous overlays
    await mapController!.clearOverlays();
    _placeMarkers.clear();
    _memberMarkers.clear();
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
    // --- 여행 멤버 위치 마커 ---
    print('[DEBUG] memberLocations: $memberLocations');
    print('[DEBUG] myNickname: $myNickname');
    if (memberLocations != null && myNickname != null) {
      final filtered =
          memberLocations
              .where((m) => m.nickname != null && m.nickname != myNickname)
              .toList();
      print('[DEBUG] filtered memberLocations:');
      for (final m in filtered) {
        print(
          'nickname: \'${m.nickname}\', lat: ${m.latitude}, lng: ${m.longitude}',
        );
      }
      for (final member in filtered) {
        print(
          '[DEBUG] adding marker: ${member.nickname}, ${member.latitude}, ${member.longitude}',
        );
        final marker = NMarker(
          id: 'member_${member.userId}',
          position: NLatLng(member.latitude, member.longitude),
          icon: NOverlayImage.fromAssetImage('asset/img/marker-pin-01.png'),
          size: Size(100.w, 100.h),
          caption: NOverlayCaption(text: member.nickname),
        );
        _memberMarkers.add(marker);
        await mapController!.addOverlay(marker);
      }
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
              // fetch가 모두 끝날 때까지 로딩만 보여줌
              if (!_allDaysFetched) {
                return const Center(child: CircularProgressIndicator());
              }
              final scheduleAsync = ref.watch(confirmScheduleProvider);
              final schedules = scheduleAsync?.schedules ?? [];
              List<ConfirmedPlaceModel> placeList = [];
              if (selectedDayIndex == 0) {
                placeList =
                    [for (final day in schedules) ...day.places]
                        .where((p) => p.latitude != null && p.longitude != null)
                        .toList();
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
                placeList =
                    daySchedule.places
                        .where((p) => p.latitude != null && p.longitude != null)
                        .toList();
              }
              final memberLocationAsync = ref.watch(tripMemberLocationProvider);
              final userMe = ref.watch(userMeProvider);
              String? myNickname;
              if (userMe is UserResponseModel && userMe.data?.nickname != null) {
                myNickname = userMe.data!.nickname;
              }
              List<TripMemberLocation>? memberLocations;
              memberLocationAsync.when(
                data: (data) {
                  memberLocations = data;
                },
                loading: () {},
                error: (_, __) {},
              );
              if (mapController != null && placeList.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateMapOverlays(
                    placeList,
                    memberLocations: memberLocations,
                    myNickname: myNickname,
                  );
                });
              }

              return NaverMap(
                onMapReady: (controller) async {
                  setState(() {
                    mapController = controller;
                  });
                  // 최초 진입 시 전체 마커 기준으로 카메라 이동 (중복 호출 방지 플래그 사용)
                  if (!_cameraFitted) {
                    List<ConfirmedPlaceModel> fitPlaces = [];
                    if (selectedDayIndex == 0) {
                      fitPlaces =
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
                            () => ConfirmedDayScheduleModel(
                              id: '',
                              day: selectedDayIndex,
                              places: [],
                            ),
                      );
                      fitPlaces =
                          daySchedule.places
                              .where(
                                (p) =>
                                    p.latitude != null && p.longitude != null,
                              )
                              .toList();
                    }
                    if (fitPlaces.isNotEmpty) {
                      await _fitMapToPlaces(fitPlaces);
                      _cameraFitted = true;
                    }
                  }
                  // ------ 최초 진입 카메라 로직
                },
                onMapTapped: (point, latLng) {
                  FocusScope.of(context).unfocus();
                },
                // ... 기타 옵션 ...
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
                              // 전체 보기: 모든 day의 place를 순서대로 합쳐서 마커/폴리라인 표시
                              final allPlaces =
                                  [for (final day in schedules) ...day.places]
                                      .where(
                                        (p) =>
                                            p.latitude != null &&
                                            p.longitude != null,
                                      )
                                      .toList();
                              if (mapController != null &&
                                  allPlaces.isNotEmpty) {
                                await _fitMapToPlaces(allPlaces);
                              } else if (mapController != null) {
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
                              // Fetch member locations and user info for overlays
                              final memberLocationAsync = ref.read(
                                tripMemberLocationProvider,
                              );
                              final userMe = ref.read(userMeProvider);
                              String? myNickname;
                              if (userMe is UserResponseModel && userMe.data?.nickname != null) {
                                myNickname = userMe.data!.nickname;
                              }
                              List<TripMemberLocation>? memberLocations;
                              memberLocationAsync.when(
                                data: (data) => memberLocations = data,
                                loading: () {},
                                error: (_, __) {},
                              );
                              _updateMapOverlays(
                                allPlaces,
                                memberLocations: memberLocations,
                                myNickname: myNickname,
                              );
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
                                // ref.invalidate(confirmScheduleProvider);// ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
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
                                final memberLocationAsync = ref.read(
                                  tripMemberLocationProvider,
                                );
                                final userMe = ref.read(userMeProvider);
                                String? myNickname;
                                if (userMe is UserModel) {
                                  myNickname = userMe.nickname;
                                }
                                List<TripMemberLocation>? memberLocations;
                                memberLocationAsync.when(
                                  data: (data) => memberLocations = data,
                                  loading: () {},
                                  error: (_, __) {},
                                );
                                _updateMapOverlays(
                                  places,
                                  memberLocations: memberLocations,
                                  myNickname: myNickname,
                                );
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
