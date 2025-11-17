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
import 'package:yeogiga/common/utils/system_ui_helper.dart';

import 'package:yeogiga/trip/provider/trip_member_location_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/trip/model/trip_member_location.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/notice/provider/ping_provider.dart';
import 'package:yeogiga/notice/model/ping_model.dart';
import 'package:yeogiga/common/utils/location_helper.dart';
import 'package:yeogiga/trip/trip_map/ing/member_marker_widget.dart';

// TODO: 여행 멤버들 위치 구해오는 provider watch하기
// TODO: 여행 멤버들 위치 구해오는 provider watch하기
// TODO: 화면 내에서는 어떻게 갱신? -> 계속해서 fcm받아가며 갱신?
// TODO: 화면 내에서는 어떻게 갱신? -> 계속해서 fcm받아가며 갱신?

class IngTripMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'ingTripMap';
  final Map<String, dynamic>? extra;

  const IngTripMapScreen({Key? key, this.extra}) : super(key: key);

  @override
  ConsumerState<IngTripMapScreen> createState() => _IngTripMapScreenState();
}

class _IngTripMapScreenState extends ConsumerState<IngTripMapScreen> {
  bool _initialized = false;
  bool _cameraFitted = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int selectedDayIndex = 0;

  // 지도/데이터 동기화용 플래그와 임시 변수

  bool _allDaysFetched = false;

  @override
  void initState() {
    super.initState();

    // Deeplink 진입 대비: TripProvider 체크 후 필요시에만 fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentTrip = ref.read(tripProvider).valueOrNull;
      final tripId = (currentTrip is TripModel) ? currentTrip.tripId : null;

      // TripProvider에 데이터가 없으면 fetch (Deeplink로 직접 진입한 경우)
      if (currentTrip == null || tripId == null) {
        // TODO: Deeplink로 tripId 파라미터 받아서 fetch
        // ref.read(tripProvider.notifier).getTrip(tripId: widget.tripId);
      }
    });

    _fetchAllDaysAndUpdateMarkers();
    _fetchPingData();
  }

  // Ping 데이터 가져오기
  Future<void> _fetchPingData() async {
    if (!mounted) return;

    final trip = ref.read(tripProvider).valueOrNull;
    if (trip is TripModel) {
      await ref.read(pingProvider.notifier).fetchPing(tripId: trip.tripId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      ref.invalidate(tripMemberLocationProvider);
      _initialized = true;
    }
  }

  Future<void> _fetchAllDaysAndUpdateMarkers() async {
    if (!mounted) return; // 추가: 초기 체크

    final trip = ref.read(tripProvider).valueOrNull as TripModel;
    // 지도에서는 fetchAll(tripId) 호출하지 않음! 이미 state에 들어온 schedules만 사용
    var scheduleAsync = ref.read(confirmScheduleProvider).valueOrNull;
    var schedules = scheduleAsync?.schedules ?? [];

    // schedules가 비어있으면 그냥 리턴 (혹시나 state 반영이 늦을 때는 잠깐 기다렸다가 한 번 더 시도)
    if (schedules.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 10));
      if (!mounted) return; // 추가: delay 후 체크

      scheduleAsync = ref.read(confirmScheduleProvider).valueOrNull;
      schedules = scheduleAsync?.schedules ?? [];
      if (schedules.isEmpty) {
        // 한 번 더 시도 (재귀, 무한루프 방지)
        return;
      }
    }

    // day별 places만 fetch
    for (final schedule in schedules) {
      if (!mounted) return; // 추가: 루프 중 체크

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

  @override
  void dispose() {
    _sheetController.dispose();
    mapController = null;
    super.dispose();
  }

  NaverMapController? mapController;
  List<NMarker> _placeMarkers = [];
  List<NMarker> _memberMarkers = [];
  NMarker? _pingMarker;
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
        NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(70.w)),
      );
    }
  }

  // 마커 업데이트
  void _updateMapOverlays(
    List<ConfirmedPlaceModel> places, {
    List<TripMemberLocation>? memberLocations,
    String? myNickname,
    PingModel? ping,
  }) async {
    if (mapController == null || !mounted) return;
    // Remove previous overlays
    try {
      if (mapController == null) return;
      await mapController!.clearOverlays();
    } catch (e) {
      // 이미 dispose된 경우 무시
      return;
    }
    _placeMarkers.clear();
    _memberMarkers.clear();
    _pingMarker = null;
    _polyline = null;

    final validPlaces =
        places.where((p) => p.latitude != null && p.longitude != null).toList();
    for (final place in validPlaces) {
      final marker = NMarker(
        id: place.id,
        position: NLatLng(place.latitude!, place.longitude!),
        icon: NOverlayImage.fromAssetImage('asset/icon/place.png'),
        size: Size(32.w, 32.h),
        caption: NOverlayCaption(text: place.name),
      );
      _placeMarkers.add(marker);
      await mapController!.addOverlay(marker);
    }
    // --- 여행 멤버 위치 마커 ---
    if (memberLocations != null && myNickname != null) {
      final filtered =
          memberLocations
              .where((m) => m.nickname != null && m.nickname != myNickname)
              .toList();
      for (final member in filtered) {
        final marker = await _createMemberMarker(member);
        _memberMarkers.add(marker);
        if (!mounted || mapController == null) return;
        await mapController!.addOverlay(marker);
      }
    }

    // --- Ping 마커 추가 ---
    if (ping != null) {
      final pingMarker = NMarker(
        id: 'ping_marker',
        position: NLatLng(ping.latitude, ping.longitude),
        icon: NOverlayImage.fromAssetImage('asset/icon/ping.png'),
        size: Size(32.w, 32.h),
        caption: NOverlayCaption(text: '집결지: ${ping.place}'),
      );
      _pingMarker = pingMarker;
      await mapController!.addOverlay(pingMarker);
    }

    // Draw polyline if 2 or more places
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
        final overlay = mapController!.getLocationOverlay();
        final lastKnown = await LocationHelper.getLastKnownPositionSafe();
        if (lastKnown != null) {
          overlay.setIsVisible(true);
          overlay.setPosition(NLatLng(lastKnown.latitude, lastKnown.longitude));
          _locationOverlay = overlay;
        }
        LocationHelper.refreshPositionAsync((pos) {
          if (!mounted || mapController == null) return;
          overlay.setIsVisible(true);
          overlay.setPosition(NLatLng(pos.latitude, pos.longitude));
          _locationOverlay = overlay;
        });
      }
    } catch (_) {}
  }

  // 내 위치로 이동하기
  Future<void> _moveToMyLocation() async {
    if (mapController == null) return;
    await LocationHelper.moveCameraToUser(controller: mapController!);
  }

  Future<NMarker> _createMemberMarker(TripMemberLocation member) async {
    final style = MemberMarkerStyle();
    final markerWidget = MemberMarkerWidget(member: member, style: style);
    final overlayImage = await NOverlayImage.fromWidget(
      widget: markerWidget,
      size: Size(style.width, style.height),
      context: context,
    );

    return NMarker(
      id: 'member_${member.userId}',
      position: NLatLng(member.latitude, member.longitude),
      icon: overlayImage,
      size: Size(style.width, style.height),
      caption: NOverlayCaption(text: member.nickname),
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
    final tripState = ref.watch(tripProvider).valueOrNull;
    final days = getDaysForTrip(tripState);

    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Consumer(
              builder: (context, ref, _) {
                // fetch가 모두 끝날 때까지 로딩만 보여줌
                if (!_allDaysFetched) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xff8287ff)),
                  );
                }
                final scheduleAsync =
                    ref.watch(confirmScheduleProvider).valueOrNull;
                final schedules = scheduleAsync?.schedules ?? [];
                List<ConfirmedPlaceModel> placeList = [];
                if (selectedDayIndex == 0) {
                  placeList =
                      [for (final day in schedules) ...day.places]
                          .where(
                            (p) => p.latitude != null && p.longitude != null,
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
                  placeList =
                      daySchedule.places
                          .where(
                            (p) => p.latitude != null && p.longitude != null,
                          )
                          .toList();
                }

                final memberLocationAsync = ref.watch(
                  tripMemberLocationProvider,
                );
                final userMe = ref.watch(userMeProvider);
                final ping = ref.watch(pingProvider);

                String? myNickname;
                if (userMe is UserResponseModel &&
                    userMe.data?.nickname != null) {
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
                if (mapController != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _updateMapOverlays(
                      placeList,
                      memberLocations: memberLocations,
                      myNickname: myNickname,
                      ping: ping,
                    );
                  });
                }

                return NaverMap(
                  onMapReady: (controller) async {
                    if (mounted) {
                      setState(() {
                        mapController = controller;
                      });
                    }

                    // TODO: PingCard에서 온 경우 ping 좌표로 카메라 이동
                    if (widget.extra != null &&
                        widget.extra!['focusPing'] == true) {
                      final pingLat = widget.extra!['pingLatitude'] as double?;
                      final pingLng = widget.extra!['pingLongitude'] as double?;
                      if (pingLat != null && pingLng != null) {
                        await controller.updateCamera(
                          NCameraUpdate.withParams(
                            target: NLatLng(pingLat, pingLng),
                            zoom: 15,
                          ),
                        );
                        _cameraFitted = true;
                        return;
                      }
                    }

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
              top: 15.h,
              left: 9.w,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.215,
              minChildSize: 0.08,
              maxChildSize: 0.215,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 3,
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
                            itemCount: days.length + 1,
                            selectedIndex: selectedDayIndex,
                            onChanged: (index) async {
                              if (mounted) {
                                setState(() {
                                  selectedDayIndex = index;
                                });
                              }
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              ); // 상태 반영 대기
                              if (!mounted) return; // delay 후 체크

                              final tripState =
                                  ref.read(tripProvider).valueOrNull;
                              final scheduleAsync =
                                  ref.read(confirmScheduleProvider).valueOrNull;
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
                                if (userMe is UserResponseModel &&
                                    userMe.data?.nickname != null) {
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
                                  ping: ref.read(pingProvider),
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
                                    ping: ref.read(pingProvider),
                                  );
                                  await _fitMapToPlaces(places);
                                }
                              }
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final scheduleAsync =
                                  ref
                                      .watch(confirmScheduleProvider)
                                      .valueOrNull;
                              final tripState =
                                  ref.watch(tripProvider).valueOrNull;
                              if (scheduleAsync == null) {
                                final trip =
                                    tripState is TripModel ? tripState : null;
                                if (trip != null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!mounted) return;
                                    ref
                                        .read(confirmScheduleProvider.notifier)
                                        .fetchAll(trip.tripId);
                                  });
                                }
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xff8287ff),
                                  ),
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
                                                category: place.placeType,
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
                                              fontSize: 14.sp,
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
    // 초기 위치 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
