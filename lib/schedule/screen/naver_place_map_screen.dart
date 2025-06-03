import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:yeogiga/naver/provider/naver_place_search_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../component/slider/pending_place_card_slider_panel.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';

class NaverPlaceMapScreen extends ConsumerStatefulWidget {
  static String get routeName => 'naverPlaceMapScreen';
  final int day; // 여행 몇일 차 정보
  final String? dayId; // 확정 일정의 dayId(고유 식별자)
  const NaverPlaceMapScreen({Key? key, required this.day, this.dayId}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    day = widget.day;
    dayId = widget.dayId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        bottomNavigationBar: _buildSliderBarHead(),
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
                  setState(() {
                    _selectedPlace = null;
                  });
                },
              ),
            ),
            // 상단 검색창
            Positioned(
              top: 170.h,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => GoRouter.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 56.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 30.w),
                        child: Container(
                          height: 138.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(48.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              SizedBox(width: 40.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20.w),
                                  child: TextField(
                                    style: TextStyle(
                                      fontSize: 44.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '...을 검색해보세요',
                                      hintStyle: TextStyle(
                                        fontSize: 44.sp,
                                        color: const Color(0xFFBDBDBD),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      setState(() => _searchQuery = value);
                                    },
                                  ),
                                ),
                              ),
                              //TODO: 검색버튼
                              GestureDetector(
                                onTap: _searchAndShowMarkers,
                                child: Icon(Icons.search),
                              ),
                              SizedBox(width: 32.w),
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
              left: 70.w,
              bottom: 200.h,
              child: _buildMyLocationButton(),
            ),
            // 하단 슬라이더바 머리부분
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: _buildSliderBarHead(),
            // ),
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

  // SettingSliderPanel: 하단 슬라이더 패널 컴포넌트 (slider 폴더에서 import)

  // ... 이하 기존 클래스 코드 ...

  // _NaverPlaceMapScreenState 내부에 아래 필드가 반드시 존재해야 함:
  // late final SlidingUpPanelController panelController = SlidingUpPanelController();
  // late final ScrollController scrollController = ScrollController();

  NaverPlaceItem? _selectedPlace;

  Widget _buildSliderBarHead() {
    // 선택된 마커가 있을 때만 패널 표시
    if (_selectedPlace == null) return SizedBox.shrink();
    return PendingPlaceCardSliderPanel(
      place: _selectedPlace,
      imageUrl: null, // 썸네일 이미지 URL 또는 null
      buttonText: '일정에 추가하기',
      onAddPressed: () {
        // TODO: 일정에 추가하기 동작 구현
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('일정에 추가되었습니다!')));
      },
    );
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
              caption: NOverlayCaption(
                text: item.title.replaceAll(RegExp(r'<.*?>'), ''),
              ),
            );
            marker.setOnTapListener((NMarker tappedMarker) {
              setState(() {
                _selectedPlace = item;
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
    // 위치 권한 체크 및 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    // 현재 위치 가져오기
    final pos = await Geolocator.getCurrentPosition();
    await mapController!.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(pos.latitude, pos.longitude),
        zoom: 15,
      ),
    );
  }
}
