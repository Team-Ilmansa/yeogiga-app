import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/no_image.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';

enum GalleryImageType { matched, unmatched, pending }

class GalleryImage {
  final String id;
  final String url;
  final int day;
  final GalleryImageType type;

  GalleryImage({
    required this.id,
    required this.url,
    required this.day,
    required this.type,
  });
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

class GalleryTab extends ConsumerStatefulWidget {
  final bool sliverMode;
  final bool showDaySelector;
  final int selectedDayIndex;
  final ValueChanged<int> onDayIndexChanged;
  final bool selectionMode;
  final ValueChanged<bool>? onSelectionModeChanged;
  final void Function({
    required Map<String, List<String>> matchedOrUnmatched,
    required Map<String, List<String>> pending,
  })
  onSelectionPayloadChanged;

  GalleryTab({
    super.key,
    required this.sliverMode,
    this.showDaySelector = true,
    required this.selectedDayIndex,
    required this.onDayIndexChanged,
    required this.selectionMode,
    required this.onSelectionModeChanged,
    required this.onSelectionPayloadChanged,
  });

  @override
  ConsumerState<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends ConsumerState<GalleryTab> {
  Set<int> selectedMatchedOrUnMatchedPictures = {};

  void setSelectionMode(bool value) {
    widget.onSelectionModeChanged?.call(value);
    if (!value) {
      setState(() {
        selectedMatchedOrUnMatchedPictures.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchedImages = ref.watch(matchedTripImagesProvider);
    final unmatchedImages = ref.watch(unmatchedTripImagesProvider);
    final pendingImages = ref.watch(pendingDayTripImagesProvider);
    final selectedDay = widget.selectedDayIndex;

    // TODO: selectedDay에 따라 사진들 분류 작업 계속 실행됨.
    List<GalleryImage> allImages = [];
    List<GalleryImage> allPendingImages = [];
    // 선택이 바뀔 때마다 호출:
    void _handleSelectionChanged() {
      final selectedImages =
          selectedMatchedOrUnMatchedPictures
              .map((idx) => allImages[idx])
              .toList();

      final matchedOrUnmatched =
          selectedImages
              .where(
                (img) =>
                    img.type == GalleryImageType.matched ||
                    img.type == GalleryImageType.unmatched,
              )
              .toList();

      final pending =
          selectedImages
              .where((img) => img.type == GalleryImageType.pending)
              .toList();

      widget.onSelectionPayloadChanged(
        matchedOrUnmatched: {
          "imageIds": matchedOrUnmatched.map((img) => img.id).toList(),
          "urls": matchedOrUnmatched.map((img) => img.url).toList(),
        },
        pending: {
          "imageIds": pending.map((img) => img.id).toList(),
          "urls": pending.map((img) => img.url).toList(),
        },
      );
    }

    // 원하는 dayselector의 사진 분류하기
    if (selectedDay == 0) {
      // 전체 날짜 이미지 합치기
      // matched
      // TODO: 어차피 사진이 있는 날만 조회하면 댐!! 개편함
      for (final dayPlace in matchedImages) {
        for (final place in dayPlace.placeImagesList) {
          if (place != null) {
            for (final img in place.placeImages) {
              allImages.add(
                GalleryImage(
                  id: img.id,
                  url: img.url,
                  day: dayPlace.day,
                  type: GalleryImageType.matched,
                ),
              );
            }
          }
        }
      }
      // unmatched
      for (final dayPlace in unmatchedImages) {
        for (final img in dayPlace.pendingImages) {
          allImages.add(
            GalleryImage(
              id: img.id,
              url: img.url,
              day: dayPlace.day,
              type: GalleryImageType.unmatched,
            ),
          );
        }
      }
      // pending
      for (final dayPlace in pendingImages) {
        for (final img in dayPlace.pendingImages) {
          // TODO: pending은 삭제가 귀찮아서 따로 관리할거임
          allPendingImages.add(
            GalleryImage(
              id: img.id,
              url: img.url,
              day: dayPlace.day,
              type: GalleryImageType.pending,
            ),
          );
        }
      }
    } else {
      // 선택된 날짜만 필터링
      allImages = [
        // matched
        for (final dayPlace in matchedImages)
          if (dayPlace.day == selectedDay)
            for (final place in dayPlace.placeImagesList)
              if (place != null)
                for (final img in place.placeImages)
                  GalleryImage(
                    id: img.id,
                    url: img.url,
                    day: dayPlace.day,
                    type: GalleryImageType.matched,
                  ),
        // unmatched
        for (final dayPlace in unmatchedImages)
          if (dayPlace.day == selectedDay)
            for (final img in dayPlace.pendingImages)
              GalleryImage(
                id: img.id,
                url: img.url,
                day: dayPlace.day,
                type: GalleryImageType.unmatched,
              ),
      ];
      // TODO: pending은 삭제가 귀찮아서 따로 관리할거임
      allPendingImages = [
        // pending
        for (final dayPlace in pendingImages)
          if (dayPlace.day == selectedDay)
            for (final img in dayPlace.pendingImages)
              GalleryImage(
                id: img.id,
                url: img.url,
                day: dayPlace.day,
                type: GalleryImageType.pending,
              ),
      ];
    }

    // detail screen에서 보여줄거 (sliver기반)
    if (widget.sliverMode) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 48.h)),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                // tripProvider에서 trip 정보를 가져와 날짜 개수를 계산
                final trip = ref.watch(tripProvider);
                int tripDayCount = 0;
                if (trip is TripModel &&
                    trip.startedAt != null &&
                    trip.endedAt != null) {
                  final start = DateTime.tryParse(trip.startedAt!);
                  final end = DateTime.tryParse(trip.endedAt!);
                  if (start != null && end != null) {
                    tripDayCount = end.difference(start).inDays + 1;
                    if (tripDayCount < 0) tripDayCount = 0;
                  }
                }
                return DaySelector(
                  itemCount: tripDayCount + 1, // +1 for '여행 전체'
                  selectedIndex: widget.selectedDayIndex,
                  onChanged: (index) {
                    widget.onDayIndexChanged(index);
                    setState(() {
                      selectedMatchedOrUnMatchedPictures.clear();
                      widget.onSelectionModeChanged?.call(false); // ✅ 이렇게 변경
                    });
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          //TODO: 그리드 뷰 부분 (사진 없으면 NoImage();)
          if (allImages.isEmpty && allPendingImages.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: 1350.h, child: NoImage()),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${allImages.length}장',
                            style: TextStyle(
                              fontSize: 60.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Color(0xff313131),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.onSelectionModeChanged?.call(
                                !widget.selectionMode,
                              );
                              if (!widget.selectionMode) {
                                setState(() {
                                  selectedMatchedOrUnMatchedPictures.clear();
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  widget.selectionMode
                                      ? '${selectedMatchedOrUnMatchedPictures.length}개 선택됨'
                                      : '선택하기',
                                  style: TextStyle(
                                    fontSize: 39.sp,
                                    letterSpacing: -0.6,
                                    color:
                                        widget.selectionMode
                                            ? Color(0xff8287ff)
                                            : Color.fromARGB(
                                              255,
                                              193,
                                              193,
                                              193,
                                            ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                SvgPicture.asset(
                                  'asset/icon/check.svg',
                                  width: 48.w,
                                  height: 48.h,
                                  color:
                                      widget.selectionMode
                                          ? Color(0xff8287ff)
                                          : Color.fromARGB(255, 193, 193, 193),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                    // TODO: 매칭 끝난 사진 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allImages.length,
                      itemBuilder: (context, idx) {
                        final image = allImages[idx];
                        final isSelected = selectedMatchedOrUnMatchedPictures
                            .contains(idx);

                        return GestureDetector(
                          onTap:
                              widget.selectionMode
                                  ? () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedMatchedOrUnMatchedPictures
                                            .remove(idx);
                                      } else {
                                        selectedMatchedOrUnMatchedPictures.add(
                                          idx,
                                        );
                                      }
                                      // 선택 상태가 바뀔 때마다 호출!
                                      _handleSelectionChanged();
                                    });
                                  }
                                  : () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding: EdgeInsets.all(100.w),
                                            child: GestureDetector(
                                              onTap:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24.r),
                                                child: Container(
                                                  color: Colors.black,
                                                  child: InteractiveViewer(
                                                    child: Image.network(
                                                      image.url,
                                                      fit: BoxFit.contain,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            progress,
                                                          ) =>
                                                              progress == null
                                                                  ? child
                                                                  : Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  ),
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            height: 400.h,
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 48.sp,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    );
                                  },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(48.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                // 타입별 표시 (오른쪽 위)
                                Positioned(
                                  top: 8.r,
                                  right: 8.r,
                                  child: _typeBadge(image.type),
                                ),
                                // 셀렉션 모드 오버레이 (원래 스타일)
                                if (widget.selectionMode && isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff8287ff).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(48.r),
                                      // TODO: 테두리 있어야하나????
                                      // border: Border.all(
                                      //   color: Color(0xff8287ff),
                                      //   width: 4.r,
                                      // ),
                                    ),
                                    // TODO: 체크표시 해놓을까????
                                    // child: Center(
                                    //   child: Icon(
                                    //     Icons.check_circle,
                                    //     color: Color.fromARGB(154, 130, 134, 255),
                                    //     size: 48.sp,
                                    //   ),
                                    // ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(48.w, 80.h, 48.w, 20.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '임시 저장 (${allPendingImages.length}장)',
                          style: TextStyle(
                            color: Color(0xff7d7d7d),
                            fontWeight: FontWeight.w600,
                            fontSize: 42.sp,
                            letterSpacing: -0.9.sp,
                          ),
                        ),
                      ),
                    ),
                    // TODO: 임시 저장 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allPendingImages.length,
                      itemBuilder: (context, idx) {
                        final image = allPendingImages[idx];

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: EdgeInsets.all(100.w),
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                        child: Container(
                                          color: Colors.black,
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              image.url,
                                              fit: BoxFit.contain,
                                              loadingBuilder:
                                                  (context, child, progress) =>
                                                      progress == null
                                                          ? child
                                                          : Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: 400.h,
                                                    color: Colors.grey[300],
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 48.sp,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(48.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                // 타입별 표시 (오른쪽 위)
                                Positioned(
                                  top: 8.r,
                                  right: 8.r,
                                  child: _typeBadge(image.type),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }, childCount: 1),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 60.h)),
        ],
      );
    }
    // end trip map에서 보여줄거 (일반버전기반)
    else {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 48.h, bottom: 60.h),
          child: Column(
            children: [
              if (widget.showDaySelector)
                // DaySelector
                Builder(
                  builder: (context) {
                    final trip = ref.watch(tripProvider);
                    int tripDayCount = 0;
                    if (trip is TripModel &&
                        trip.startedAt != null &&
                        trip.endedAt != null) {
                      final start = DateTime.tryParse(trip.startedAt!);
                      final end = DateTime.tryParse(trip.endedAt!);
                      if (start != null && end != null) {
                        tripDayCount = end.difference(start).inDays + 1;
                        if (tripDayCount < 0) tripDayCount = 0;
                      }
                    }

                    return DaySelector(
                      itemCount: tripDayCount + 1,
                      selectedIndex: widget.selectedDayIndex,
                      onChanged: (index) {
                        widget.onDayIndexChanged(index);
                        setState(() {
                          selectedMatchedOrUnMatchedPictures.clear();
                          widget.onSelectionModeChanged?.call(false);
                        });
                      },
                    );
                  },
                ),
              SizedBox(height: 20.h),

              // NoImage or Image Section
              if (allImages.isEmpty && allPendingImages.isEmpty)
                SizedBox(height: 1350.h, child: NoImage())
              else
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${allImages.length}장',
                            style: TextStyle(
                              fontSize: 60.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Color(0xff313131),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.onSelectionModeChanged?.call(
                                !widget.selectionMode,
                              );
                              if (!widget.selectionMode) {
                                setState(() {
                                  selectedMatchedOrUnMatchedPictures.clear();
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  widget.selectionMode
                                      ? '${selectedMatchedOrUnMatchedPictures.length}개 선택됨'
                                      : '선택하기',
                                  style: TextStyle(
                                    fontSize: 39.sp,
                                    letterSpacing: -0.6,
                                    color:
                                        widget.selectionMode
                                            ? Color(0xff8287ff)
                                            : Color.fromARGB(
                                              255,
                                              193,
                                              193,
                                              193,
                                            ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                SvgPicture.asset(
                                  'asset/icon/check.svg',
                                  width: 48.w,
                                  height: 48.h,
                                  color:
                                      widget.selectionMode
                                          ? Color(0xff8287ff)
                                          : Color.fromARGB(255, 193, 193, 193),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // 매칭 끝난 사진 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allImages.length,
                      itemBuilder: (context, idx) {
                        final image = allImages[idx];
                        final isSelected = selectedMatchedOrUnMatchedPictures
                            .contains(idx);
                        return GestureDetector(
                          onTap:
                              widget.selectionMode
                                  ? () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedMatchedOrUnMatchedPictures
                                            .remove(idx);
                                      } else {
                                        selectedMatchedOrUnMatchedPictures.add(
                                          idx,
                                        );
                                      }
                                      _handleSelectionChanged();
                                    });
                                  }
                                  : () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding: EdgeInsets.all(100.w),
                                            child: GestureDetector(
                                              onTap:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24.r),
                                                child: Container(
                                                  color: Colors.black,
                                                  child: InteractiveViewer(
                                                    child: Image.network(
                                                      image.url,
                                                      fit: BoxFit.contain,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            progress,
                                                          ) =>
                                                              progress == null
                                                                  ? child
                                                                  : Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  ),
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            height: 400.h,
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 48.sp,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    );
                                  },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(48.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                // 타입별 표시 (오른쪽 위)
                                Positioned(
                                  top: 8.r,
                                  right: 8.r,
                                  child: _typeBadge(image.type),
                                ),
                                // 셀렉션 모드 오버레이 (원래 스타일)
                                if (widget.selectionMode && isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff8287ff).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(48.r),
                                      // TODO: 테두리 있어야하나????
                                      // border: Border.all(
                                      //   color: Color(0xff8287ff),
                                      //   width: 4.r,
                                      // ),
                                    ),
                                    // TODO: 체크표시 해놓을까????
                                    // child: Center(
                                    //   child: Icon(
                                    //     Icons.check_circle,
                                    //     color: Color.fromARGB(154, 130, 134, 255),
                                    //     size: 48.sp,
                                    //   ),
                                    // ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(48.w, 80.h, 48.w, 20.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '임시 저장 (${allPendingImages.length}장)',
                          style: TextStyle(
                            color: Color(0xff7d7d7d),
                            fontWeight: FontWeight.w600,
                            fontSize: 42.sp,
                            letterSpacing: -0.9.sp,
                          ),
                        ),
                      ),
                    ),
                    // TODO: 임시 저장 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allPendingImages.length,
                      itemBuilder: (context, idx) {
                        final image = allPendingImages[idx];

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: EdgeInsets.all(100.w),
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                        child: Container(
                                          color: Colors.black,
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              image.url,
                                              fit: BoxFit.contain,
                                              loadingBuilder:
                                                  (context, child, progress) =>
                                                      progress == null
                                                          ? child
                                                          : Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: 400.h,
                                                    color: Colors.grey[300],
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 48.sp,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(48.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                // 타입별 표시 (오른쪽 위)
                                Positioned(
                                  top: 8.r,
                                  right: 8.r,
                                  child: _typeBadge(image.type),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
  }
}

// TODO: 타입 뱃지 위젯 임시
// TODO: 타입 뱃지 위젯 임시
Widget _typeBadge(GalleryImageType type) {
  switch (type) {
    case GalleryImageType.matched:
      return Icon(Icons.check_circle, color: Colors.green, size: 28.sp);
    case GalleryImageType.unmatched:
      return Icon(Icons.error, color: Colors.red, size: 28.sp);
    case GalleryImageType.pending:
      return Icon(Icons.hourglass_empty, color: Colors.orange, size: 28.sp);
  }
}
