import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/trip_image/view/trip_image_more_menu_sheet.dart';
import 'package:yeogiga/trip_image/repository/trip_image_repository.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';

class TripImageView extends ConsumerStatefulWidget {
  static String get routeName => 'tripImageView';
  final List<GalleryImage> images;
  final int initialIndex;
  final int tripId;

  const TripImageView({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.tripId,
  });

  @override
  ConsumerState<TripImageView> createState() => _TripImageViewState();
}

class _TripImageViewState extends ConsumerState<TripImageView> {
  late PageController _pageController;
  late int _currentIndex;
  late List<GalleryImage> _images;
  bool _isFavoriteUpdating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _images = List.from(widget.images);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleImageDelete() {
    if (_images.isEmpty) return;
    setState(() {
      final wasLastImage = _images.length == 1;
      _images.removeAt(_currentIndex);

      if (wasLastImage) {
        Navigator.pop(context);
        return;
      }

      if (_currentIndex >= _images.length) {
        _currentIndex = _images.length - 1;
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat dateFormat = DateFormat('yyyy. MM. dd a hh:mm', 'ko_KR');
    return dateFormat.format(dateTime);
  }

  Future<void> _toggleFavorite() async {
    if (_images.isEmpty || _isFavoriteUpdating) return;
    final current = _images[_currentIndex];
    final tripDayPlaceId = current.tripDayPlaceId;
    if (tripDayPlaceId == null || widget.tripId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 정보를 불러오는 중입니다. 다시 시도해주세요.')),
      );
      return;
    }

    final newValue = !current.favorite;
    setState(() {
      _isFavoriteUpdating = true;
      _images[_currentIndex] = current.copyWith(favorite: newValue);
    });

    final repo = ref.read(tripImageRepositoryProvider);
    try {
      await repo.updateFavorite(
        tripId: widget.tripId,
        tripDayPlaceId: tripDayPlaceId,
        imageId: current.id,
        placeId: current.placeId,
        favorite: newValue,
      );

      if (current.type == GalleryImageType.matched) {
        ref.read(matchedTripImagesProvider.notifier).updateFavorite(
          current.id,
          newValue,
        );
      } else if (current.type == GalleryImageType.unmatched) {
        ref.read(unmatchedTripImagesProvider.notifier).updateFavorite(
          current.id,
          newValue,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _images[_currentIndex] = current;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '즐겨찾기 변경에 실패했습니다. 다시 시도해주세요. (${e.toString()})',
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isFavoriteUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return SafeArea(
        top: false,
        bottom: shouldUseSafeAreaBottom(context),
        child: Scaffold(
          backgroundColor: const Color(0xfffafafa),
          appBar: AppBar(
            scrolledUnderElevation: 0,
            toolbarHeight: 48.h,
            backgroundColor: const Color(0xfffafafa),
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
              ),
            ),
            title: Text(
              '사진이 없습니다',
              style: TextStyle(
                color: const Color(0xFF313131),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.48,
              ),
            ),
          ),
          body: Center(
            child: Text(
              '표시할 사진이 없습니다.',
              style: TextStyle(
                color: const Color(0xff7d7d7d),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: Scaffold(
        backgroundColor: Color(0xfffafafa),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          toolbarHeight: 48.h,
          backgroundColor: Color(0xfffafafa),
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
            ),
          ),
          title: Column(
            children: [
              Text(
                _images[_currentIndex].placeName ??
                    (_images[_currentIndex].type == GalleryImageType.pending
                        ? '임시 저장'
                        : '기타'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.40,
                  letterSpacing: -0.48,
                ),
              ),
              if (_images[_currentIndex].date != null)
                Text(
                  _formatDateTime(_images[_currentIndex].date!),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF313131),
                    fontSize: 10,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                    letterSpacing: -0.30,
                  ),
                ),
            ],
          ),
          actions: [
            // pending이 아닐 때만 좋아요 버튼 표시
            if (_images.isNotEmpty &&
                _images[_currentIndex].type != GalleryImageType.pending)
              Material(
                color: Color(0xfffafafa),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: _isFavoriteUpdating ? null : _toggleFavorite,
                  child: Padding(
                    padding: EdgeInsets.all(4.sp),
                    child: SvgPicture.asset(
                      _images[_currentIndex].favorite
                          ? 'asset/icon/favorite on.svg'
                          : 'asset/icon/favorite off.svg',
                    ),
                  ),
                ),
              ),
            if (_images.isNotEmpty &&
                _images[_currentIndex].type != GalleryImageType.pending)
              SizedBox(width: 5.w),
            Material(
              color: Color(0xfffafafa),
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    useSafeArea: shouldUseSafeAreaBottom(context),
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black.withOpacity(0.5),
                    builder: (context) {
                      if (_images.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return TripImageMoreMenuSheet(
                        currentImage: _images[_currentIndex],
                        onImageDeleted: _handleImageDelete,
                      );
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(3.sp),
                  child: Icon(Icons.more_vert, color: Colors.black),
                ),
              ),
            ),
            SizedBox(width: 14.w),
          ],
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  _images[index].url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
