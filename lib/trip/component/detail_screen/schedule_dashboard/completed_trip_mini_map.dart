import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';

class CompletedTripMiniMap extends StatefulWidget {
  final List<CompletedTripDayPlaceModel> dayPlaceModels;
  final VoidCallback? onTap;
  const CompletedTripMiniMap({
    Key? key,
    required this.dayPlaceModels,
    this.onTap,
  }) : super(key: key);

  @override
  State<CompletedTripMiniMap> createState() => _CompletedTripMiniMapState();
}

class _CompletedTripMiniMapState extends State<CompletedTripMiniMap> {
  NaverMapController? _controller;

  List<NLatLng> get _allPlaces =>
      widget.dayPlaceModels
          .expand((day) => day.places)
          .map((place) => NLatLng(place.latitude, place.longitude))
          .toList();

  NLatLng get _center =>
      _allPlaces.isNotEmpty
          ? _allPlaces.first
          : const NLatLng(37.5665, 126.9780);

  @override
  void didUpdateWidget(covariant CompletedTripMiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted || _controller == null) return;
    if (oldWidget.dayPlaceModels != widget.dayPlaceModels) {
      _updateMarkers();
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _updateMarkers() async {
    if (_controller == null) return;
    try {
      await _controller!.clearOverlays();
      if (_allPlaces.isEmpty) return;
      for (final latLng in _allPlaces) {
        await _controller!.addOverlay(
          NMarker(id: latLng.toString(), position: latLng),
        );
      }
    } catch (e, st) {
      debugPrint('NaverMap clearOverlays/addOverlay error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlaces = _allPlaces;
    final center = _center;

    if (allPlaces.isEmpty) {
      _controller = null;
      return SizedBox(
        height: 600.h,
        child: Center(
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
        ),
      );
    }

    return SizedBox(
      height: 600.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(54.r),
        child: Stack(
          children: [
            NaverMap(
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
                _controller = controller;
                await _updateMarkers();
              },
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
