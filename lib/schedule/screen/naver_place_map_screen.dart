import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:yeogiga/common/utils/location_helper.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/common/utils/snackbar_helper.dart';
import 'package:yeogiga/naver/provider/naver_place_search_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../component/slider/place_card_slider_panel.dart';
import '../component/slider/ping_select_panel.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/notice/provider/ping_provider.dart';

class NaverPlaceMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'naverPlaceMapScreen';
  final int day; // 여행 몇일 차 정보
  final String? dayId; // 확정 일정의 dayId(고유 식별자)
  const NaverPlaceMapScreen({Key? key, required this.day, this.dayId})
    : super(key: key);

  @override
  ConsumerState<NaverPlaceMapScreen> createState() =>
      _NaverPlaceMapScreenState();
}

class _NaverPlaceMapScreenState extends ConsumerState<NaverPlaceMapScreen> {
  // 여행 몇일 차 정보 (부모 위젯에서 받음)
  late final int day;
  late final String? dayId; // 확정 일정의 dayId(고유 식별자)

  // 최근 검색된 장소 리스트(마커 매칭용)
  List<NaverPlaceItem>? _searchResultItems;
  // 예시: 지도 컨트롤러, 검색어, 위치 등
  NaverMapController? mapController;
  String _searchQuery = '';

  bool _showSliderBar = false;

  @override
  void initState() {
    super.initState();
    day = widget.day;
    dayId = widget.dayId;
    // 슬라이드 애니메이션 트리거
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showSliderBar = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: Scaffold(
        // bottomNavigationBar: AnimatedSlide(
        //   offset: _showSliderBar ? Offset(0, 0) : Offset(0, 1),
        //   duration: const Duration(milliseconds: 400),
        //   curve: Curves.easeOutCubic,
        //   child: _buildSliderBarHead(),
        // ),
        body: Stack(
          children: [
            // 네이버 지도 위젯 (실제 연동 시 아래 주석 해제 및 교체)

            // DEMO: 격자무늬 배경 (실제 지도 대신)
            Positioned.fill(
              child: NaverMap(
                onMapReady: (controller) {
                  mapController = controller;
                },
                onMapTapped: (point, latLng) {
                  FocusScope.of(context).unfocus();
                  // [애니메이션] 패널을 슬라이드다운(숨김) 애니메이션 시작
                  setState(() {
                    _showSliderBar = false;
                  });
                  // [애니메이션] AnimatedSlide의 duration(400ms)만큼 기다렸다가, 패널 위젯 자체를 제거
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted) {
                      setState(() {
                        _selectedPlace = null;
                      });
                    }
                  });
                },
              ),
            ),
            // 상단 검색창
            Positioned(
              top: 51.h,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 9.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => GoRouter.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9.w),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 17.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 9.w),
                        child: Container(
                          height: 41.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 1.r,
                                offset: Offset(0, 1.h),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 6.w),
                                  child: TextField(
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '...을 검색해보세요',
                                      hintStyle: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFFBDBDBD),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      setState(() => _searchQuery = value);
                                    },
                                    onSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                      _searchAndShowMarkers();
                                    },
                                  ),
                                ),
                              ),
                              //TODO: 검색버튼
                              GestureDetector(
                                onTap: _searchAndShowMarkers,
                                child: Icon(Icons.search),
                              ),
                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 내 위치로 가기 버튼
            Positioned(
              left: 21.w,
              bottom: 59.h,
              child: _buildMyLocationButton(),
            ),
            // 하단 슬라이더바 머리부분
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: _buildSliderBarHead(),
            // ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                // [애니메이션] 패널이 보일 조건: _selectedPlace가 null이 아니고, _showSliderBar가 true일 때만 슬라이드업
                // 그렇지 않으면 슬라이드다운(숨김) 애니메이션
                // 이 조건은 마커 클릭 시, 지도 탭 시, 패널이 보일 때와 숨길 때 애니메이션을 트리거하는 데 사용됨
                offset:
                    _selectedPlace != null && _showSliderBar
                        ? Offset(0, 0)
                        : Offset(0, 1),
                duration: const Duration(
                  milliseconds: 400,
                ), // 애니메이션 속도: 400ms로 설정하여 부드러운 슬라이드 효과를 냄
                curve: Curves.easeOutCubic, // 부드러운 슬라이드 효과를 위한 곡선
                child: _buildSliderBarHead(),
              ),
            ),
          ],
        ),
      ),
    );
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
          width: 36.w,
          height: 36.w,
          child: Icon(
            Icons.my_location_outlined,
            color: Colors.black,
            size: 18.sp,
          ),
        ),
      ),
    );
  }

  // SettingSliderPanel: 하단 슬라이더 패널 컴포넌트 (slider 폴더에서 import)

  // ... 이하 기존 클래스 코드 ...

  // _NaverPlaceMapScreenState 내부에 아래 필드가 반드시 존재해야 함:
  // late final SlidingUpPanelController panelController = SlidingUpPanelController();
  // late final ScrollController scrollController = ScrollController();

  NaverPlaceItem? _selectedPlace;

  Widget _buildSliderBarHead() {
    // 선택된 마커가 있을 때만 패널 표시
    if (_selectedPlace == null) return SizedBox.shrink();

    // pingSelectionMode 상태 확인
    final isPingSelectionMode = ref.watch(pingSelectionModeProvider);
    final tripState = ref.read(tripProvider).valueOrNull;

    if (isPingSelectionMode) {
      // 집결지 추가 모드일 때
      return PingSelectPanel(
        place: _selectedPlace,
        imageUrl: null,
        trip: tripState is TripModel ? tripState : null,
        onAddPressed: (DateTime selectedDateTime) async {
          if (tripState is TripModel && _selectedPlace != null) {
            // 집결지 생성 API 호출
            final result = await ref
                .read(pingProvider.notifier)
                .createPing(
                  tripId: tripState.tripId,
                  place: _selectedPlace!.title,
                  latitude: _selectedPlace!.mapyCoord,
                  longitude: _selectedPlace!.mapxCoord,
                  time: selectedDateTime,
                );

            if (mounted) {
              showAppSnackBar(
                context,
                result['success']
                    ? '집결지가 성공적으로 설정되었습니다!'
                    : result['message'],
                isError: !(result['success'] as bool),
              );

              if (result['success']) {
                ref.read(pingSelectionModeProvider.notifier).state = false;
              }
              context.pop();
              // }
            }
          }
        },
      );
    } else {
      // 일반 일정 추가 모드일 때
      return PlaceCardSliderPanel(
        place: _selectedPlace,
        imageUrl: null, // 썸네일 이미지 URL 또는 null
        buttonText: '일정에 추가하기',
        onAddPressed: (selectedCategoryIndex) async {
          // 카테고리 index를 문자열로 변환
          String placeType;
          switch (selectedCategoryIndex) {
            case 1:
              placeType = 'TOURISM';
              break;
            case 2:
              placeType = 'LODGING';
              break;
            case 3:
              placeType = 'RESTAURANT';
              break;
            case 4:
              placeType = 'TRANSPORT';
              break;
            case 5:
              placeType = 'ETC';
              break;
            default:
              placeType = 'TOURISM'; // 기본값
          }

          print('선택된 카테고리: $placeType (index: $selectedCategoryIndex)');
          final tripState = ref.read(tripProvider).valueOrNull;
          if (tripState is TripModel) {
            bool success = false;
            String? errorMsg;
            try {
              if (tripState.status == TripStatus.SETTING) {
                // Pending 일정에 추가 (provider만 사용)
                success = await ref
                    .read(pendingScheduleProvider.notifier)
                    .addPlace(
                      tripId: tripState.tripId.toString(),
                      day: day,
                      id: _selectedPlace!.link,
                      name: _selectedPlace!.title,
                      latitude: _selectedPlace!.mapyCoord,
                      longitude: _selectedPlace!.mapxCoord,
                      placeType: placeType,
                      address: _selectedPlace!.address,
                    );
              } else {
                // Confirmed 일정에 추가 (provider만 사용)
                if (dayId != null) {
                  success = await ref
                      .read(confirmScheduleProvider.notifier)
                      .addPlace(
                        tripId: tripState.tripId,
                        tripDayPlaceId: dayId!,
                        name: _selectedPlace!.title,
                        latitude: _selectedPlace!.mapyCoord,
                        longitude: _selectedPlace!.mapxCoord,
                        placeType: placeType,
                        address: _selectedPlace!.address,
                      );
                }
              }
            } catch (e) {
              success = false;
              if (e is Exception && e.toString().contains('Exception:')) {
                errorMsg = e.toString().replaceFirst('Exception:', '').trim();
              } else {
                errorMsg = e.toString();
              }
            }

            // 성공 시 슬라이더바 내리기
            if (success) {
              setState(() {
                _showSliderBar = false;
              });
              // 애니메이션 완료 후 선택된 장소도 초기화
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) {
                  setState(() {
                    _selectedPlace = null;
                  });
                }
              });
            }

            // 수정: async gap 이후 context 사용 시 mounted 체크 추가
            if (mounted) {
              showAppSnackBar(
                context,
                success
                    ? '일정에 성공적으로 추가되었습니다!'
                    : '일정 추가에 실패했습니다${errorMsg != null ? "\n$errorMsg" : ""}',
                isError: !success,
              );
            }
          }
        },
      );
    }
  }

  Future<void> _searchAndShowMarkers() async {
    final value = _searchQuery;
    if (value.trim().isNotEmpty && mapController != null) {
      final result = await ref.read(naverPlaceSearchProvider(value).future);
      // 검색 결과를 상태에 저장 (마커 매칭용)
      _searchResultItems = result.items;
      // 기존 마커 모두 제거
      await mapController!.clearOverlays();
      // 마커 좌표 리스트
      final List<NLatLng> markerPositions =
          result.items
              .map((item) => NLatLng(item.mapyCoord, item.mapxCoord))
              .toList();
      // 새 마커 Set으로 생성 (좌표 변환 메서드 사용!)
      final markers =
          result.items.map((item) {
            final marker = NMarker(
              id: item.title,
              position: NLatLng(item.mapyCoord, item.mapxCoord),
              icon: NOverlayImage.fromAssetImage('asset/icon/place.png'),
              size: Size(32.w, 32.h),
              caption: NOverlayCaption(
                text: item.title.replaceAll(RegExp(r'<.*?>'), ''),
              ),
            );
            marker.setOnTapListener((NMarker tappedMarker) {
              // [애니메이션] 같은 마커를 연속 클릭해도 항상 슬라이드 애니메이션이 동작하도록
              setState(() {
                _showSliderBar = false;
                _selectedPlace = null; // 먼저 null로 바꿔 AnimatedSlide를 완전히 숨김
              });
              // 10ms 후 실제 마커 데이터로 다시 할당해 슬라이드업 애니메이션 트리거
              Future.delayed(const Duration(milliseconds: 10), () {
                if (mounted) {
                  setState(() {
                    _selectedPlace = item;
                    _showSliderBar = true;
                  });
                }
              });
            });
            return marker;
          }).toSet();
      await mapController!.addOverlayAll(markers);
      // 모든 마커가 보이도록 카메라 이동
      if (markerPositions.isNotEmpty) {
        if (markerPositions.length == 1) {
          // 마커 1개: 해당 위치로 적당한 줌
          await mapController!.updateCamera(
            NCameraUpdate.withParams(target: markerPositions.first, zoom: 15),
          );
        } else {
          // 여러 개: bounds로 fit
          double minLat = markerPositions.first.latitude;
          double maxLat = markerPositions.first.latitude;
          double minLng = markerPositions.first.longitude;
          double maxLng = markerPositions.first.longitude;
          for (final pos in markerPositions) {
            if (pos.latitude < minLat) minLat = pos.latitude;
            if (pos.latitude > maxLat) maxLat = pos.latitude;
            if (pos.longitude < minLng) minLng = pos.longitude;
            if (pos.longitude > maxLng) maxLng = pos.longitude;
          }
          final bounds = NLatLngBounds(
            southWest: NLatLng(minLat, minLng),
            northEast: NLatLng(maxLat, maxLng),
          );
          await mapController!.updateCamera(
            NCameraUpdate.fitBounds(
              bounds,
              padding: EdgeInsets.only(
                left: 80,
                right: 80,
                top: 80,
                bottom: 80,
              ),
            ),
          );
        }
      }
    } else if (mapController != null) {
      await mapController!.clearOverlays();
    }
  }

  Future<void> _moveToMyLocation() async {
    if (mapController == null) return;
    await LocationHelper.moveCameraToUser(controller: mapController!);
  }
}
