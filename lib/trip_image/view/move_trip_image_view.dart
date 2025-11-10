import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/component/grey_bar.dart';
import 'package:yeogiga/common/component/simple_loading_dialog.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';
import 'package:yeogiga/trip/utils/gallery_refresh_helper.dart';
import 'package:yeogiga/trip_image/component/selectable_schedule_item.dart';

class MoveTripImageArgs {
  final GalleryImage image;
  const MoveTripImageArgs({required this.image});
}

class MoveTripImageView extends ConsumerStatefulWidget {
  static String get routeName => 'moveTripImageView';
  final MoveTripImageArgs args;
  const MoveTripImageView({super.key, required this.args});

  @override
  ConsumerState<MoveTripImageView> createState() => _MoveTripImageViewState();
}

class _MoveTripImageViewState extends ConsumerState<MoveTripImageView> {
  late final GalleryImage _image;
  late final bool _isMatched;
  late final bool _isUnmatched;
  int? _selectedDayValue;
  String? _selectedTripDayPlaceId;
  String? _selectedPlaceId;
  bool _selectedEtc = false;
  ConfirmedPlaceModel? _selectedPlace;
  bool _initializedSchedule = false;
  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _image = widget.args.image;
    _isMatched = _image.type == GalleryImageType.matched;
    _isUnmatched = _image.type == GalleryImageType.unmatched;
    _selectedDayValue = _image.day;
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider).valueOrNull;
    final confirmed = ref.watch(confirmScheduleProvider).valueOrNull;

    // 최초 진입 시 데이터 로드
    if (confirmed == null && tripState is TripModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(confirmScheduleProvider.notifier).fetchAll(tripState.tripId);
      });
    }

    final schedules = confirmed?.schedules ?? [];
    final filteredSchedules =
        _isMatched
            ? schedules
            : schedules.where((s) => s.day == _image.day).toList();

    if (!_initializedSchedule && filteredSchedules.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetDay = _selectedDayValue ?? filteredSchedules.first.day;
        final schedule = filteredSchedules.firstWhere(
          (s) => s.day == targetDay,
          orElse: () => filteredSchedules.first,
        );
        setState(() {
          _selectedDayValue = schedule.day;
          _selectedTripDayPlaceId = schedule.id;
          _initializedSchedule = true;
        });
      });
    }

    final currentSchedule = filteredSchedules.firstWhere(
      (s) => s.day == _selectedDayValue,
      orElse:
          () =>
              filteredSchedules.isNotEmpty
                  ? filteredSchedules.first
                  : ConfirmedDayScheduleModel(id: '', day: 0, places: []),
    );

    final showDaySelector = _isMatched && filteredSchedules.length > 1;
    final dayOptions = filteredSchedules.map((s) => s.day).toList();
    int selectedDayIndex = 0;
    if (dayOptions.isNotEmpty) {
      final idx = dayOptions.indexOf(_selectedDayValue ?? _image.day);
      selectedDayIndex = idx >= 0 ? idx : 0;
    }
    final showEtcOption =
        _isMatched &&
        (_selectedDayValue ?? _image.day) == _image.day &&
        currentSchedule.places.isNotEmpty;
    final canMove = _canMove(showEtcOption);

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
            '사진 위치 옮기기',
            style: TextStyle(
              color: const Color(0xFF313131),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.48,
            ),
          ),
        ),
        body:
            confirmed == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                  children: [
                    Column(
                      children: [
                        if (showDaySelector)
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 12.h, 0, 16.h),
                            child: DaySelector(
                              itemCount: dayOptions.length,
                              selectedIndex: selectedDayIndex,
                              onChanged: (index) {
                                if (index < 0 || index >= dayOptions.length) {
                                  return;
                                }
                                final day = dayOptions[index];
                                final schedule = filteredSchedules.firstWhere(
                                  (s) => s.day == day,
                                  orElse: () => filteredSchedules.first,
                                );
                                setState(() {
                                  _selectedDayValue = schedule.day;
                                  _selectedTripDayPlaceId = schedule.id;
                                  _selectedPlaceId = null;
                                  _selectedPlace = null;
                                  _selectedEtc = false;
                                });
                              },
                              labelBuilder:
                                  (index) => 'DAY ${dayOptions[index]}',
                            ),
                          )
                        else
                          SizedBox(height: 12.h),
                        //여기
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: const [
                                  Colors.transparent,
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.05],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 500.h),
                              child: Column(
                                children: [
                                  SizedBox(height: 10.h),
                                  if (currentSchedule.places.isNotEmpty)
                                    ...currentSchedule.places.map(
                                      (place) => SelectableScheduleItem(
                                        title: place.name,
                                        category: place.placeType,
                                        selected: _selectedPlaceId == place.id,
                                        done: place.isVisited,
                                        onTap: () {
                                          setState(() {
                                            _selectedPlaceId = place.id;
                                            _selectedPlace = place;
                                            _selectedTripDayPlaceId =
                                                currentSchedule.id;
                                            _selectedEtc = false;
                                          });
                                        },
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 100.h,
                                      ),
                                      child: Text(
                                        '등록된 일정이 없습니다.',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFFC6C6C6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  if (showEtcOption)
                                    SelectableScheduleItem(
                                      title: '기타(매칭 해제)',
                                      category: '매칭해제',
                                      selected: _selectedEtc,
                                      done: false,
                                      onTap: () {
                                        setState(() {
                                          _selectedEtc = true;
                                          _selectedPlaceId = null;
                                          _selectedPlace = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 하단 고정 바
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: GreyBar()),
                            // 제목
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    // TextSpan(
                                    //   text: '1',
                                    //   style: TextStyle(
                                    //     color: const Color(0xFF8287FF),
                                    //     fontSize: 20.sp,
                                    //     fontFamily: 'Pretendard',
                                    //     fontWeight: FontWeight.w700,
                                    //     height: 1.40,
                                    //     letterSpacing: -0.60,
                                    //   ),
                                    // ),
                                    TextSpan(
                                      text: '사진을 ',
                                      style: TextStyle(
                                        color: const Color(0xFF313131),
                                        fontSize: 20.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w700,
                                        height: 1.40,
                                        letterSpacing: -0.60,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _targetLabel(showEtcOption),
                                      style: TextStyle(
                                        color: const Color(0xFF8287FF),
                                        fontSize: 20.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w700,
                                        height: 1.40,
                                        letterSpacing: -0.60,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '(으)로 옮길까요?',
                                      style: TextStyle(
                                        color: const Color(0xFF313131),
                                        fontSize: 20.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w700,
                                        height: 1.40,
                                        letterSpacing: -0.60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // 설명
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    // TextSpan(
                                    //   text: '1장의 사진이 ',
                                    //   style: TextStyle(
                                    //     color: const Color(0xFF7D7D7D),
                                    //     fontSize: 14.sp,
                                    //     fontFamily: 'Pretendard',
                                    //     fontWeight: FontWeight.w500,
                                    //     height: 1.40,
                                    //     letterSpacing: -0.42,
                                    //   ),
                                    // ),
                                    TextSpan(
                                      text: '$_originLabel',
                                      style: TextStyle(
                                        color: const Color(0xFF8287FF),
                                        fontSize: 14.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40,
                                        letterSpacing: -0.42,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '에서 ',
                                      style: TextStyle(
                                        color: const Color(0xFF7D7D7D),
                                        fontSize: 14.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40,
                                        letterSpacing: -0.42,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\n${_targetLabel(showEtcOption)}',
                                      style: TextStyle(
                                        color: const Color(0xFF8287FF),
                                        fontSize: 14.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40,
                                        letterSpacing: -0.42,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '(으)로 이동합니다.\n내가 사진을 옮기면 다른 팀원들에게도 바뀐 위치로 적용돼요.',
                                      style: TextStyle(
                                        color: const Color(0xFF7D7D7D),
                                        fontSize: 14.sp,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40,
                                        letterSpacing: -0.42,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: AspectRatio(
                                  aspectRatio: 2 / 1,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        _image.url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          return Container(
                                            color: const Color(0xFFE0E0E0),
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              size: 32.sp,
                                              color: const Color(0xFF9E9E9E),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        left: 12.w,
                                        top: 12.h,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.45,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          child: Text(
                                            'DAY ${_image.day} · ${_originLabel}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 19.h),

                            // 사진 옮기기 버튼
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: SizedBox(
                                width: double.infinity,
                                height: 52.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8287FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed:
                                      canMove
                                          ? () => _handleMove(confirmed)
                                          : null,
                                  child: Text(
                                    '사진 옮기기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  String _targetLabel(bool showEtcOption) {
    if (_selectedEtc && showEtcOption) return '기타(매칭 해제)';
    return _selectedPlace?.name ?? '목적지를 선택해주세요';
  }

  String get _originLabel => _image.placeName ?? '기타';

  bool _canMove(bool showEtcOption) {
    if (_isMatched) {
      final isSameDay = (_selectedDayValue ?? _image.day) == _image.day;
      if (!isSameDay) {
        return _selectedPlaceId != null && _selectedTripDayPlaceId != null;
      }
      if (_selectedEtc && showEtcOption) {
        return true;
      }
      if (_selectedPlaceId == null || _selectedTripDayPlaceId == null) {
        return false;
      }
      if (_selectedPlaceId == _image.placeId) {
        return false;
      }
      return true;
    } else if (_isUnmatched) {
      return _selectedPlaceId != null && _selectedTripDayPlaceId != null;
    }
    return false;
  }

  Future<void> _handleMove(ConfirmedScheduleModel? confirmed) async {
    if (confirmed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정을 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }
    final tripState = ref.read(tripProvider).valueOrNull;
    if (tripState is! TripModel) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('여행 정보를 불러올 수 없습니다.')));
      return;
    }

    final tripId = tripState.tripId;
    final selectedTripDayPlaceId = _selectedTripDayPlaceId;
    final repo = ref.read(matchedTripImageRepository);

    try {
      final messenger = ScaffoldMessenger.of(context);
      _showLoading();

      if (_isMatched) {
        final fromTripDayPlaceId = _image.tripDayPlaceId;
        final fromPlaceId = _image.placeId;
        if (fromTripDayPlaceId == null || fromPlaceId == null) {
          throw '사진의 목적지 정보를 찾을 수 없습니다.';
        }

        final isSameDay = (_selectedDayValue ?? _image.day) == _image.day;

        if (!isSameDay) {
          if (_selectedPlaceId == null || selectedTripDayPlaceId == null) {
            throw '이동할 목적지를 선택해주세요.';
          }
          await repo.moveMatchedImageToDifferentDay(
            tripId: tripId,
            fromTripDayPlaceId: fromTripDayPlaceId,
            fromPlaceId: fromPlaceId,
            toTripDayPlaceId: selectedTripDayPlaceId,
            toPlaceId: _selectedPlaceId!,
            imageId: _image.id,
          );
        } else {
          if (_selectedEtc) {
            await repo.moveMatchedImageToUnmatched(
              tripId: tripId,
              tripDayPlaceId: fromTripDayPlaceId,
              placeId: fromPlaceId,
              imageId: _image.id,
            );
          } else {
            if (_selectedPlaceId == null || selectedTripDayPlaceId == null) {
              throw '이동할 목적지를 선택해주세요.';
            }
            if (_selectedPlaceId == fromPlaceId) {
              throw '같은 목적지로는 이동할 수 없습니다.';
            }
            await repo.moveMatchedImageSameDay(
              tripId: tripId,
              tripDayPlaceId: selectedTripDayPlaceId,
              fromPlaceId: fromPlaceId,
              toPlaceId: _selectedPlaceId!,
              imageId: _image.id,
            );
          }
        }
      } else if (_isUnmatched) {
        if (selectedTripDayPlaceId == null || _selectedPlaceId == null) {
          throw '이동할 목적지를 선택해주세요.';
        }
        await repo.moveUnmatchedImageToMatched(
          tripId: tripId,
          tripDayPlaceId: selectedTripDayPlaceId,
          placeId: _selectedPlaceId!,
          imageId: _image.id,
        );
      }

      await GalleryRefreshHelper.refreshAll(ref);
      _closeLoading();
      if (!mounted) return;
      final updatedImage = _buildUpdatedImage();
      Navigator.of(context).pop(updatedImage);
      messenger.showSnackBar(const SnackBar(content: Text('사진 위치가 변경되었습니다.')));
    } catch (e) {
      _closeLoading();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  GalleryImage _buildUpdatedImage() {
    if (_isMatched) {
      final isSameDay = (_selectedDayValue ?? _image.day) == _image.day;
      if (!isSameDay) {
        return _image.copyWith(
          day: _selectedDayValue ?? _image.day,
          tripDayPlaceId: _selectedTripDayPlaceId ?? _image.tripDayPlaceId,
          placeId: _selectedPlaceId ?? _image.placeId,
          placeName: _selectedPlace?.name ?? _image.placeName,
          type: GalleryImageType.matched,
        );
      }

      if (_selectedEtc) {
        return GalleryImage(
          id: _image.id,
          url: _image.url,
          day: _image.day,
          type: GalleryImageType.unmatched,
          placeName: null,
          tripDayPlaceId: _image.tripDayPlaceId,
          placeId: null,
          date: null,
          favorite: _image.favorite,
        );
      }

      return _image.copyWith(
        tripDayPlaceId: _selectedTripDayPlaceId ?? _image.tripDayPlaceId,
        placeId: _selectedPlaceId ?? _image.placeId,
        placeName: _selectedPlace?.name ?? _image.placeName,
      );
    } else if (_isUnmatched) {
      return GalleryImage(
        id: _image.id,
        url: _image.url,
        day: _image.day,
        type: GalleryImageType.matched,
        placeName: _selectedPlace?.name ?? _image.placeName,
        tripDayPlaceId: _selectedTripDayPlaceId ?? _image.tripDayPlaceId,
        placeId: _selectedPlaceId ?? _image.placeId,
        date: _image.date,
        favorite: _image.favorite,
      );
    }

    return _image;
  }

  void _showLoading() {
    if (_loadingShown) return;
    _loadingShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SimpleLoadingDialog(message: '잠시만 기다려주세요'),
    ).then((_) {
      _loadingShown = false;
    });
  }

  void _closeLoading() {
    if (_loadingShown && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _loadingShown = false;
    }
  }
}
