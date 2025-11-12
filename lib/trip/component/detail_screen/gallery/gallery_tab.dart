import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/no_image.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';
import 'package:yeogiga/trip/provider/gallery_selection_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/common/utils/snackbar_helper.dart';

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

class GalleryTab extends ConsumerStatefulWidget {
  //sliver - detailscreen, nonsliver - endmap
  final bool sliverMode;
  final bool showDaySelector;
  final int selectedDayIndex;
  final ValueChanged<int> onDayIndexChanged;

  GalleryTab({
    super.key,
    required this.sliverMode,
    this.showDaySelector = true,
    required this.selectedDayIndex,
    required this.onDayIndexChanged,
  });

  @override
  ConsumerState<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends ConsumerState<GalleryTab> {
  @override
  Widget build(BuildContext context) {
    final selectionMode = ref.watch(selectionModeProvider);
    final selectedDay = widget.selectedDayIndex;

    // ✅ 새로운 computed provider 사용 - 이미지 분류 로직이 자동 캐싱됨
    final allImages = ref.watch(filteredGalleryImagesProvider(selectedDay));
    final allPendingImages = ref.watch(
      filteredPendingImagesProvider(selectedDay),
    );

    // ✅ 선택 상태를 provider로 관리
    final selectedIndices = ref.watch(gallerySelectionProvider);
    final trip = ref.watch(tripProvider).valueOrNull;
    final int? tripId = trip is TripModel ? trip.tripId : null;

    // selection mode가 꺼지면 선택 해제
    if (!selectionMode && selectedIndices.isNotEmpty) {
      print('[GalleryTab] selection mode OFF이고 선택된 항목 있음 -> clear 호출');
      Future.microtask(() {
        ref.read(gallerySelectionProvider.notifier).clear();
      });
    }

    // detail screen에서 보여줄거 (sliver기반)
    if (widget.sliverMode) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 14.h)),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
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
                return trip is SettingTripModel &&
                        (trip.startedAt == null || trip.endedAt == null)
                    ? Container()
                    : DaySelector(
                      itemCount: tripDayCount + 1, // +1 for '여행 전체'
                      selectedIndex: widget.selectedDayIndex,
                      onChanged: (index) {
                        widget.onDayIndexChanged(index);
                        // ✅ provider를 사용하여 선택 해제
                        ref.read(gallerySelectionProvider.notifier).clear();
                        ref.read(selectionModeProvider.notifier).state = false;
                      },
                    );
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 6.h)),
          //TODO: 그리드 뷰 부분 (사진 없으면 NoImage();)
          if (allImages.isEmpty && allPendingImages.isEmpty)
            SliverToBoxAdapter(child: SizedBox(height: 401.h, child: NoImage()))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${allImages.length}장',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                              color: Color(0xff313131),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(selectionModeProvider.notifier).state =
                                  !selectionMode;
                              if (!ref.read(selectionModeProvider)) {
                                ref
                                    .read(gallerySelectionProvider.notifier)
                                    .clear();
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  selectionMode
                                      ? '${selectedIndices.length}개 선택됨'
                                      : '선택하기',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    letterSpacing: -0.2,
                                    color:
                                        selectionMode
                                            ? Color(0xff8287ff)
                                            : Color.fromARGB(
                                              255,
                                              193,
                                              193,
                                              193,
                                            ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                SvgPicture.asset(
                                  'asset/icon/check.svg',
                                  width: 14.w,
                                  height: 14.h,
                                  color:
                                      selectionMode
                                          ? Color(0xff8287ff)
                                          : Color.fromARGB(255, 193, 193, 193),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),
                    // TODO: 매칭 끝난 사진 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 4.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allImages.length,
                      itemBuilder: (context, idx) {
                        final image = allImages[idx];
                        final isSelected = selectedIndices.contains(idx);

                        return GestureDetector(
                          onTap:
                              selectionMode
                                  ? () {
                                    print(
                                      '[GalleryTab] matched/unmatched 이미지 탭: idx=$idx, type=${image.type}',
                                    );
                                    // ✅ provider를 사용하여 선택 토글 (ref.listen이 자동으로 payload 업데이트)
                                    ref
                                        .read(gallerySelectionProvider.notifier)
                                        .toggle(idx);
                                  }
                                  : () {
                                    if (tripId == null) {
                                      showAppSnackBar(
                                        context,
                                        '여행 정보를 불러오는 중입니다. 다시 시도해주세요.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    context.push(
                                      '/tripImageView',
                                      extra: {
                                        'images': allImages,
                                        'initialIndex': idx,
                                        'tripId': tripId,
                                      },
                                    );
                                  },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                if (image.favorite)
                                  Positioned(
                                    top: 4.r,
                                    right: 4.r,
                                    child: SvgPicture.asset(
                                      'asset/icon/favorite on.svg',
                                      width: 16.w,
                                      height: 16.h,
                                    ),
                                  ),
                                // 타입별 표시 (오른쪽 위)
                                // Positioned(
                                //   top: 2.r,
                                //   right: 2.r,
                                //   child: _typeBadge(image.type),
                                // ),
                                // 셀렉션 모드 오버레이 (원래 스타일)
                                if (selectionMode && isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff8287ff).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(14.r),
                                      // TODO: 테두리 있어야하나????
                                      // border: Border.all(
                                      //   color: Color(0xff8287ff),
                                      //   width: 1.r,
                                      // ),
                                    ),
                                    // TODO: 체크표시 해놓을까????
                                    // child: Center(
                                    //   child: Icon(
                                    //     Icons.check_circle,
                                    //     color: Color.fromARGB(154, 130, 134, 255),
                                    //     size: 14.sp,
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
                      padding: EdgeInsets.fromLTRB(14.w, 24.h, 14.w, 6.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '임시 저장 (${allPendingImages.length}장)',
                          style: TextStyle(
                            color: Color(0xff7d7d7d),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            letterSpacing: -0.3.sp,
                          ),
                        ),
                      ),
                    ),
                    // TODO: 임시 저장 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 4.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allPendingImages.length,
                      itemBuilder: (context, idx) {
                        final image = allPendingImages[idx];
                        // pending 이미지의 실제 인덱스 = matched/unmatched 개수 + pending idx
                        final actualIndex = allImages.length + idx;
                        final isSelected = selectedIndices.contains(
                          actualIndex,
                        );

                        return GestureDetector(
                          onTap:
                              selectionMode
                                  ? () {
                                    print(
                                      '[GalleryTab] pending 이미지 탭: idx=$idx, actualIndex=$actualIndex',
                                    );
                                    // ✅ pending 이미지도 선택 가능 (ref.listen이 자동으로 payload 업데이트)
                                    ref
                                        .read(gallerySelectionProvider.notifier)
                                        .toggle(actualIndex);
                                  }
                                  : () {
                                    if (tripId == null) {
                                      showAppSnackBar(
                                        context,
                                        '여행 정보를 불러오는 중입니다. 다시 시도해주세요.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    final pendingGalleryImages =
                                        allPendingImages
                                            .map(
                                              (img) => GalleryImage(
                                                id: img.id,
                                                url: img.url,
                                                day: img.day,
                                                type: GalleryImageType.pending,
                                                placeName: null,
                                                tripDayPlaceId:
                                                    img.tripDayPlaceId,
                                                favorite: false,
                                              ),
                                            )
                                            .toList();

                                    context.push(
                                      '/tripImageView',
                                      extra: {
                                        'images': pendingGalleryImages,
                                        'initialIndex': idx,
                                        'tripId': tripId,
                                      },
                                    );
                                  },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                if (image.favorite)
                                  Positioned(
                                    top: 6.r,
                                    right: 6.r,
                                    child: SvgPicture.asset(
                                      'asset/icon/favorite on.svg',
                                      width: 16.w,
                                      height: 16.h,
                                    ),
                                  ),
                                if (image.favorite)
                                  Positioned(
                                    top: 4.r,
                                    right: 4.r,
                                    child: SvgPicture.asset(
                                      'asset/icon/favorite on.svg',
                                      width: 16.w,
                                      height: 16.h,
                                    ),
                                  ),
                                // 타입별 표시 (오른쪽 위)
                                // Positioned(
                                //   top: 2.r,
                                //   right: 2.r,
                                //   child: _typeBadge(image.type),
                                // ),
                                // ✅ 셀렉션 모드 오버레이 (matched/unmatched와 동일)
                                if (selectionMode && isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff8287ff).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
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
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
        ],
      );
    }
    // end trip map에서 보여줄거 (일반버전기반)
    else {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 14.h, bottom: 18.h),
          child: Column(
            children: [
              if (widget.showDaySelector)
                // DaySelector
                Builder(
                  builder: (context) {
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
                        // ✅ provider를 사용하여 선택 해제
                        ref.read(gallerySelectionProvider.notifier).clear();
                        ref.read(selectionModeProvider.notifier).state = false;
                      },
                    );
                  },
                ),
              SizedBox(height: 6.h),

              // NoImage or Image Section
              if (allImages.isEmpty && allPendingImages.isEmpty)
                SizedBox(height: 401.h, child: NoImage())
              else
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${allImages.length}장',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                              color: Color(0xff313131),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(selectionModeProvider.notifier).state =
                                  !selectionMode;
                              if (!selectionMode) {
                                ref
                                    .read(gallerySelectionProvider.notifier)
                                    .clear();
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  selectionMode
                                      ? '${selectedIndices.length}개 선택됨'
                                      : '선택하기',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    letterSpacing: -0.2,
                                    color:
                                        selectionMode
                                            ? Color(0xff8287ff)
                                            : Color.fromARGB(
                                              255,
                                              193,
                                              193,
                                              193,
                                            ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                SvgPicture.asset(
                                  'asset/icon/check.svg',
                                  width: 14.w,
                                  height: 14.h,
                                  color:
                                      selectionMode
                                          ? Color(0xff8287ff)
                                          : Color.fromARGB(255, 193, 193, 193),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),

                    // 매칭 끝난 사진 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 4.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allImages.length,
                      itemBuilder: (context, idx) {
                        final image = allImages[idx];
                        final isSelected = selectedIndices.contains(idx);
                        return GestureDetector(
                          onTap:
                              selectionMode
                                  ? () {
                                    // ✅ provider를 사용하여 선택 토글
                                    ref
                                        .read(gallerySelectionProvider.notifier)
                                        .toggle(idx);
                                  }
                                  : () {
                                    if (tripId == null) {
                                      showAppSnackBar(
                                        context,
                                        '여행 정보를 불러오는 중입니다. 다시 시도해주세요.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    context.push(
                                      '/tripImageView',
                                      extra: {
                                        'images': allImages,
                                        'initialIndex': idx,
                                        'tripId': tripId,
                                      },
                                    );
                                  },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                if (image.favorite)
                                  Positioned(
                                    top: 4.r,
                                    right: 4.r,
                                    child: SvgPicture.asset(
                                      'asset/icon/favorite on.svg',
                                      width: 16.w,
                                      height: 16.h,
                                    ),
                                  ),
                                // 타입별 표시 (오른쪽 위)
                                // Positioned(
                                //   top: 2.r,
                                //   right: 2.r,
                                //   child: _typeBadge(image.type),
                                // ),
                                // 셀렉션 모드 오버레이 (원래 스타일)
                                if (selectionMode && isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff8287ff).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(14.r),
                                      // TODO: 테두리 있어야하나????
                                      // border: Border.all(
                                      //   color: Color(0xff8287ff),
                                      //   width: 1.r,
                                      // ),
                                    ),
                                    // TODO: 체크표시 해놓을까????
                                    // child: Center(
                                    //   child: Icon(
                                    //     Icons.check_circle,
                                    //     color: Color.fromARGB(154, 130, 134, 255),
                                    //     size: 14.sp,
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
                      padding: EdgeInsets.fromLTRB(14.w, 24.h, 14.w, 6.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '임시 저장 (${allPendingImages.length}장)',
                          style: TextStyle(
                            color: Color(0xff7d7d7d),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            letterSpacing: -0.3.sp,
                          ),
                        ),
                      ),
                    ),
                    // TODO: 임시 저장 그리드뷰
                    GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 4.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: allPendingImages.length,
                      itemBuilder: (context, idx) {
                        final image = allPendingImages[idx];
                        // pending 이미지의 실제 인덱스 = matched/unmatched 개수 + pending idx
                        final actualIndex = allImages.length + idx;
                        final isSelected = selectedIndices.contains(
                          actualIndex,
                        );

                        return GestureDetector(
                          onTap:
                              selectionMode
                                  ? () {
                                    print(
                                      '[GalleryTab] pending 이미지 탭: idx=$idx, actualIndex=$actualIndex',
                                    );
                                    // ✅ pending 이미지도 선택 가능 (ref.listen이 자동으로 payload 업데이트)
                                    ref
                                        .read(gallerySelectionProvider.notifier)
                                        .toggle(actualIndex);
                                  }
                                  : () {
                                    if (tripId == null) {
                                      showAppSnackBar(
                                        context,
                                        '여행 정보를 불러오는 중입니다. 다시 시도해주세요.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    final pendingGalleryImages =
                                        allPendingImages
                                            .map(
                                              (img) => GalleryImage(
                                                id: img.id,
                                                url: img.url,
                                                day: img.day,
                                                type: GalleryImageType.pending,
                                                placeName: null,
                                                tripDayPlaceId:
                                                    img.tripDayPlaceId,
                                                favorite: false,
                                              ),
                                            )
                                            .toList();

                                    context.push(
                                      '/tripImageView',
                                      extra: {
                                        'images': pendingGalleryImages,
                                        'initialIndex': idx,
                                        'tripId': tripId,
                                      },
                                    );
                                  },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300]),
                                  ),
                                ),
                                if (image.favorite)
                                  Positioned(
                                    top: 4.r,
                                    right: 4.r,
                                    child: SvgPicture.asset(
                                      'asset/icon/favorite on.svg',
                                      width: 16.w,
                                      height: 16.h,
                                    ),
                                  ),
                                // 타입별 표시 (오른쪽 위)
                                // Positioned(
                                //   top: 2.r,
                                //   right: 2.r,
                                //   child: _typeBadge(image.type),
                                // ),
                                // ✅ 셀렉션 모드 오버레이 (matched/unmatched와 동일)
                                if (selectionMode && isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff8287ff).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
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
Widget _typeBadge(GalleryImageType type) {
  switch (type) {
    case GalleryImageType.matched:
      return Icon(Icons.check_circle, color: Colors.green, size: 8.sp);
    case GalleryImageType.unmatched:
      return Icon(Icons.error, color: Colors.red, size: 8.sp);
    case GalleryImageType.pending:
      return Icon(Icons.hourglass_empty, color: Colors.orange, size: 8.sp);
  }
}
