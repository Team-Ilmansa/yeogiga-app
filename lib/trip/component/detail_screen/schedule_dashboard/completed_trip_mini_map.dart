import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';

class CompletedTripMiniMap extends StatelessWidget {
  final List<CompletedTripDayPlaceModel> dayPlaceModels;
  const CompletedTripMiniMap({Key? key, required this.dayPlaceModels})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 모든 목적지 좌표 수집
    final List<NLatLng> allPlaces =
        dayPlaceModels
            .expand((day) => day.places)
            .map((place) => NLatLng(place.latitude, place.longitude))
            .toList();

    // 중심좌표 계산 (없으면 서울시청)
    final NLatLng center =
        allPlaces.isNotEmpty
            ? allPlaces.first
            : const NLatLng(37.5665, 126.9780);

    return SizedBox(
      height: 600.h,
      child:
          allPlaces.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 80.sp,
                      color: const Color(0xffc6c6c6),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      '등록된 목적지가 없습니다.',
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: const Color(0xffc6c6c6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(54.r),
                child: NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: center,
                      zoom: 11,
                    ),
                    locationButtonEnable: false,
                    indoorEnable: false,
                    scaleBarEnable: false,
                    logoAlign: NLogoAlign.leftBottom,
                  ),
                  onMapReady: (controller) async {
                    await controller.clearOverlays();
                    for (final latLng in allPlaces) {
                      await controller.addOverlay(
                        NMarker(id: latLng.toString(), position: latLng),
                      );
                    }
                  },
                ),
              ),
    );
  }
}
