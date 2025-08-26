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
  bool _isFittingCamera = false;

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
      _updateMarkersAndFitCamera();
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _updateMarkersAndFitCamera() async {
    if (_controller == null || _isFittingCamera) return;
    _isFittingCamera = true;
    try {
      await _controller!.clearOverlays();
      final places = _allPlaces;
      if (places.isEmpty) return;
      for (final latLng in places) {
        await _controller!.addOverlay(
          NMarker(id: latLng.toString(), position: latLng),
        );
      }
      // 카메라 자동 fit
      if (places.length == 1) {
        await _controller!.updateCamera(
          NCameraUpdate.withParams(
            target: places.first,
            zoom: 7, // 기존 13에서 살짝 축소
          ),
        );
      } else if (places.length >= 2) {
        final lats = places.map((p) => p.latitude).toList();
        final lngs = places.map((p) => p.longitude).toList();
        final southWest = NLatLng(
          lats.reduce((a, b) => a < b ? a : b),
          lngs.reduce((a, b) => a < b ? a : b),
        );
        final northEast = NLatLng(
          lats.reduce((a, b) => a > b ? a : b),
          lngs.reduce((a, b) => a > b ? a : b),
        );
        final bounds = NLatLngBounds(
          southWest: southWest,
          northEast: northEast,
        );
        await _controller!.updateCamera(
          NCameraUpdate.fitBounds(
            bounds,
            padding: EdgeInsets.all(30.w),
          ), // 기존 60.w에서 100.w로 padding 확대
        );
      }
    } catch (e, st) {
      debugPrint('NaverMap clearOverlays/addOverlay error: $e\n$st');
    } finally {
      _isFittingCamera = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlaces = _allPlaces;
    final center = _center;

    if (allPlaces.isEmpty) {
      _controller = null;
      return SizedBox(
        height: 178.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 24.sp,
                color: const Color(0xffc6c6c6),
              ),
              SizedBox(height: 7.h),
              Text(
                '등록된 목적지가 없습니다.',
                style: TextStyle(
                  fontSize: 11.sp,
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
      height: 178.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(target: center, zoom: 3),
                locationButtonEnable: false,
                indoorEnable: false,
                scaleBarEnable: false,
                logoAlign: NLogoAlign.leftBottom,
              ),
              onMapReady: (controller) async {
                _controller = controller;
                await _updateMarkersAndFitCamera();
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
