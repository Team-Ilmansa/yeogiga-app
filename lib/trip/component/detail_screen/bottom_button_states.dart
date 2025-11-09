import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yeogiga/notice/provider/notice_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/trip/trip_map/end/end_trip_map.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';
import 'package:yeogiga/trip_image/repository/trip_image_repository.dart';
import 'package:yeogiga/trip/provider/gallery_selection_provider.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';
import 'package:yeogiga/common/component/simple_loading_dialog.dart';
import 'package:yeogiga/trip/utils/gallery_refresh_helper.dart';
import '../../../schedule/provider/confirm_schedule_provider.dart';

Future<bool> requestImagePermission() async {
  if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
    return true;
  }
  if (await Permission.photos.request().isGranted ||
      await Permission.storage.request().isGranted) {
    return true;
  }
  return false;
}

void _showBlockingLoadingDialog(
  BuildContext context, {
  String message = '잠시만 기다려주세요',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.1),
    builder: (_) => SimpleLoadingDialog(message: message),
  );
}

class AddNoticeState extends ConsumerWidget {
  const AddNoticeState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48.h,
      child: Row(
        children: [
          // Expanded(
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Color(0xff8287ff),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12.r),
          //       ),
          //       minimumSize: Size.fromHeight(46.h),
          //       elevation: 0,
          //       padding: EdgeInsets.zero,
          //     ),
          //     onPressed: () {
          //       // TODO: 일정 추가 액션
          //     },
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         SvgPicture.asset(
          //           'asset/icon/add_schedule.svg',
          //           width: 21.w,
          //           height: 21.h,
          //         ),
          //         SizedBox(width: 9.w),
          //         Text(
          //           '일정 추가하기',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 14.sp,
          //             fontWeight: FontWeight.w600,
          //             letterSpacing: -0.1,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(width: 11.w),
          SizedBox(width: 6.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff8287ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                minimumSize: Size.fromHeight(46.h),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                _showAddNoticeModal(context, ref);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'asset/icon/gong_ji.svg',
                    width: 21.w,
                    height: 21.h,
                  ),
                  SizedBox(width: 9.w),
                  Text(
                    '공지 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }
}

class AddNoticeAndPingState extends ConsumerWidget {
  const AddNoticeAndPingState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      child: Row(
        children: [
          // Expanded(
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Color(0xff8287ff),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12.r),
          //       ),
          //       minimumSize: Size.fromHeight(46.h),
          //       elevation: 0,
          //       padding: EdgeInsets.zero,
          //     ),
          //     onPressed: () {
          //       // TODO: 일정 추가 액션
          //     },
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         SvgPicture.asset(
          //           'asset/icon/add_schedule.svg',
          //           width: 21.w,
          //           height: 21.h,
          //         ),
          //         SizedBox(width: 9.w),
          //         Text(
          //           '일정 추가하기',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 14.sp,
          //             fontWeight: FontWeight.w600,
          //             letterSpacing: -0.1,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(width: 6.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff8287ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                minimumSize: Size.fromHeight(46.h),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                // pingSelectionModeProvider를 true로 설정
                ref.read(pingSelectionModeProvider.notifier).state = true;

                // naver_place_map_screen으로 이동
                context.push('/naverPlaceMapScreen');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'asset/icon/ping_white.svg',
                    width: 21.w,
                    height: 21.h,
                  ),
                  SizedBox(width: 9.w),
                  Text(
                    '집결지 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
              ),
            ),
          ),

          SizedBox(width: 11.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff8287ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                minimumSize: Size.fromHeight(46.h),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                _showAddNoticeModal(context, ref);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'asset/icon/gong_ji.svg',
                    width: 21.w,
                    height: 21.h,
                  ),
                  SizedBox(width: 9.w),
                  Text(
                    '공지 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
              ),
            ),
          ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }
}

class AddPictureState extends ConsumerStatefulWidget {
  final int selectedDayIndex;
  const AddPictureState({super.key, required this.selectedDayIndex});

  @override
  ConsumerState<AddPictureState> createState() => _AddPictureState();
}

class _AddPictureState extends ConsumerState<AddPictureState> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String tripDayPlaceId = '';
    return SizedBox(
      height: 48.h,
      child: PageView(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        children: [
          // 사진 업로드 버튼
          Row(
            children: [
              SizedBox(width: 6.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8287ff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size.fromHeight(46.h),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    print('[사진 업로드] 버튼 클릭');
                    if (widget.selectedDayIndex == 0) {
                      print('[사진 업로드] 날짜 미선택');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('날짜를 선택해주세요')));
                      return;
                    }

                    final tripAsync = ref.read(tripProvider);
                    print('[사진 업로드] tripAsync 타입: ${tripAsync.runtimeType}');
                    final tripState = tripAsync.valueOrNull;
                    print('[사진 업로드] tripState 타입: ${tripState?.runtimeType}');
                    if (tripState is! InProgressTripModel &&
                        tripState is! CompletedTripModel) {
                      print('[사진 업로드] 잘못된 tripState 타입으로 종료');
                      return;
                    }
                    final tripId = (tripState as dynamic).tripId;
                    print('[사진 업로드] tripId: $tripId');

                    // 완료된 여행이라면?
                    if (tripState is CompletedTripModel) {
                      final completed =
                          ref.watch(completedScheduleProvider).valueOrNull;

                      final match = completed!.data.firstWhere(
                        (e) => e.day == widget.selectedDayIndex,
                      );
                      print('[ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ] $match');
                      tripDayPlaceId = match.id;

                      // 진행중인 여행이라면?
                    } else if (tripState is InProgressTripModel) {
                      final confirmed =
                          ref.watch(confirmScheduleProvider).valueOrNull;
                      if (confirmed != null && confirmed.schedules.isNotEmpty) {
                        final match = confirmed.schedules.firstWhere(
                          (e) => e.day == widget.selectedDayIndex,
                        );
                        tripDayPlaceId = match.id;
                      }
                    }

                    print('[사진 업로드] 권한 체크 시작');
                    final hasPermission = await requestImagePermission();
                    print('[사진 업로드] 권한 체크 결과: $hasPermission');

                    if (!hasPermission) {
                      // 수정: async gap 이후 context 사용 시 mounted 체크 추가
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('권한을 설정해주세요'),
                          action: SnackBarAction(
                            label: '설정으로 이동',
                            onPressed: () {
                              openAppSettings();
                            },
                          ),
                        ),
                      );
                      return;
                    }

                    print('[사진 업로드] FilePicker 시작');
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                          withData: true,
                        );

                    if (result == null || result.files.isEmpty) {
                      // 수정: async gap 이후 context 사용 시 mounted 체크 추가
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('사진을 선택하지 않았습니다.')),
                      );
                      return;
                    }

                    List<File> files =
                        result.paths.map((path) => File(path!)).toList();

                    final notifier = ref.read(
                      pendingDayTripImagesProvider.notifier,
                    );

                    for (final picked in result.files) {
                      final bytes =
                          picked.bytes ??
                          await File(picked.path!).readAsBytes();
                      final tags = await readExifFromBytes(bytes);

                      if (tags.isEmpty) {
                        print('EXIF 정보 없음');
                      } else {
                        tags.forEach((key, value) {
                          print('$key: $value');
                        });
                      }
                    }

                    // 로딩 모달 표시
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => _UploadingDialog(),
                    );

                    final success = await notifier.uploadImages(
                      tripId: tripId,
                      tripDayPlaceId: tripDayPlaceId,
                      images: files,
                    );

                    if (success) {
                      print('[사진 업로드] 업로드 성공, fetch 시작');

                      // ⏰ S3 업로드 완료를 위한 딜레이 (1.5초)
                      print('[사진 업로드] S3 업로드 대기 중...');
                      await Future.delayed(const Duration(milliseconds: 1500));
                      print('[사진 업로드] 대기 완료, fetch 시작');

                      // ✅ 업로드한 day만 refresh (31개 → 1개 API 호출)
                      print(
                        '[사진 업로드] fetchDay: tripId=$tripId, day=${widget.selectedDayIndex}, tripDayPlaceId=$tripDayPlaceId',
                      );
                      await ref
                          .read(pendingDayTripImagesProvider.notifier)
                          .fetchDay(
                            tripId,
                            widget.selectedDayIndex,
                            tripDayPlaceId,
                          );
                      print('[사진 업로드] fetchDay 완료');

                      // 로딩 모달 닫기
                      if (!mounted) return;
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('사진 업로드 완료!'),
                          backgroundColor: const Color.fromARGB(
                            212,
                            56,
                            212,
                            121,
                          ),
                        ),
                      );
                    } else {
                      // 로딩 모달 닫기
                      if (!mounted) return;
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('사진 업로드 실패. 다시 시도해 주세요.')),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'asset/icon/add_picture.svg',
                        width: 21.w,
                        height: 21.h,
                      ),
                      SizedBox(width: 9.w),
                      Text(
                        widget.selectedDayIndex == 0
                            ? '날짜를 선택해주세요'
                            : '${widget.selectedDayIndex}일 차 사진 업로드하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 12.sp),
            ],
          ),
          // 사진 매핑/리매핑 버튼 (두 개를 Row로 묶어서 한 페이지에)
          Row(
            children: [
              Icon(Icons.chevron_left, size: 12.sp),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8287ff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size.fromHeight(46.h),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    List<String> tripDayPlaceIds = [];
                    // TODO: 사진 매핑 api 호출
                    final tripAsync = ref.read(tripProvider);
                    final tripState = tripAsync.valueOrNull;
                    if (tripState is! InProgressTripModel &&
                        tripState is! CompletedTripModel) {
                      return;
                    }
                    final tripId = (tripState as dynamic).tripId;

                    // 완료된 여행이라면?
                    if (tripState is CompletedTripModel) {
                      final completed =
                          ref.watch(completedScheduleProvider).valueOrNull;

                      tripDayPlaceIds =
                          completed!.data.map((e) => e.id).toList();

                      // 진행중인 여행이라면?
                    } else if (tripState is InProgressTripModel) {
                      final confirmed =
                          ref.watch(confirmScheduleProvider).valueOrNull;
                      tripDayPlaceIds =
                          confirmed!.schedules.map((e) => e.id).toList();
                    }

                    final notifier = ref.read(
                      pendingDayTripImagesProvider.notifier,
                    );
                    bool dialogOpened = false;
                    if (context.mounted) {
                      dialogOpened = true;
                      _showBlockingLoadingDialog(context);
                    }
                    try {
                      final success = await notifier.assignImages(
                        tripId: tripId,
                        tripDayPlaceIds: tripDayPlaceIds,
                      );

                      if (success) {
                        await GalleryRefreshHelper.refreshAll(ref);
                        if (dialogOpened && context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('사진 매핑 완료!'),
                            backgroundColor: const Color.fromARGB(
                              212,
                              56,
                              212,
                              121,
                            ),
                          ),
                        );
                      } else {
                        if (dialogOpened && context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('사진 매핑 실패. 다시 시도해 주세요.')),
                        );
                      }
                    } catch (e, st) {
                      print('사진 매핑 중 예외 발생: $e\n$st');
                      if (dialogOpened && context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('사진 매핑 실패. 다시 시도해 주세요.')),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '사진 맵핑하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8287ff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size.fromHeight(46.h),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    // TODO: 사진 리매핑 api 호출
                    List<String> tripDayPlaceIds = [];
                    final tripAsync = ref.read(tripProvider);
                    final tripState = tripAsync.valueOrNull;
                    if (tripState is! InProgressTripModel &&
                        tripState is! CompletedTripModel) {
                      return;
                    }
                    final tripId = (tripState as dynamic).tripId;

                    // 완료된 여행이라면?
                    if (tripState is CompletedTripModel) {
                      final completed =
                          ref.watch(completedScheduleProvider).valueOrNull;

                      tripDayPlaceIds =
                          completed!.data.map((e) => e.id).toList();

                      // 진행중인 여행이라면?
                    } else if (tripState is InProgressTripModel) {
                      final confirmed =
                          ref.watch(confirmScheduleProvider).valueOrNull;
                      tripDayPlaceIds =
                          confirmed!.schedules.map((e) => e.id).toList();
                    }

                    final notifier = ref.read(
                      matchedTripImagesProvider.notifier,
                    );

                    bool dialogOpened = false;
                    if (context.mounted) {
                      dialogOpened = true;
                      _showBlockingLoadingDialog(context);
                    }

                    try {
                      final success = await notifier.reassignImagesToPlaces(
                        tripId: tripId,
                        tripDayPlaceIds: tripDayPlaceIds,
                      );

                      if (success) {
                        await GalleryRefreshHelper.refreshAll(ref);
                        if (dialogOpened && context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('사진 리매핑 완료!'),
                            backgroundColor: const Color.fromARGB(
                              212,
                              56,
                              212,
                              121,
                            ),
                          ),
                        );
                      } else {
                        if (dialogOpened && context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('사진 리매핑 실패. 다시 시도해 주세요.')),
                        );
                      }
                    } catch (e, st) {
                      print('사진 리매핑 중 예외 발생: $e\n$st');
                      if (dialogOpened && context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '리매핑하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6.w),
            ],
          ),
        ],
      ),
    );
  }
}

class PictureOptionState extends ConsumerWidget {
  final int selectedDayIndex;

  PictureOptionState({super.key, required this.selectedDayIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ provider에서 직접 선택된 이미지 정보 가져오기
    final selectedIndices = ref.watch(gallerySelectionProvider);
    final allImages = ref.watch(
      filteredGalleryImagesProvider(selectedDayIndex),
    );
    final allPendingImages = ref.watch(
      filteredPendingImagesProvider(selectedDayIndex),
    );

    // 선택된 이미지 계산 (모든 버튼에서 공통으로 사용)
    final allCombinedImages = [...allImages, ...allPendingImages];
    final selectedImages =
        selectedIndices
            .where((idx) => idx < allCombinedImages.length)
            .map((idx) => allCombinedImages[idx])
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

    final matchedImageIds = matchedOrUnmatched.map((img) => img.id).toList();
    final matchedUrls = matchedOrUnmatched.map((img) => img.url).toList();
    final pendingImageIds = pending.map((img) => img.id).toList();
    final pendingUrls = pending.map((img) => img.url).toList();

    return Transform.translate(
      offset: const Offset(0, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              onPressed: () async {
                print('[PictureOption] 삭제 버튼 클릭');
                final tripAsync = ref.read(tripProvider);
                final tripState = tripAsync.valueOrNull;
                if (tripState == null) return;
                final tripId = (tripState as dynamic).tripId;

                print('[PictureOption] matchedImageIds: $matchedImageIds');
                print('[PictureOption] matchedUrls: $matchedUrls');
                print('[PictureOption] pendingImageIds: $pendingImageIds');
                print('[PictureOption] pendingUrls: $pendingUrls');

                // 선택된 이미지가 하나도 없으면
                if (matchedImageIds.isEmpty && pendingImageIds.isEmpty) {
                  print('[PictureOption] 선택된 이미지 없음');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('삭제할 사진을 선택하세요.')));
                  return;
                }

                // ✅ 삭제 확인 모달 표시
                final totalCount =
                    matchedImageIds.length + pendingImageIds.length;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => ConfirmationDialog(
                        title: '사진 삭제',
                        content:
                            '사진 ${totalCount}장을 삭제하시겠습니까?\n삭제된 사진은 복구할 수 없습니다.',
                        confirmText: '삭제',
                        confirmColor: const Color(0xFFFF5C5C),
                      ),
                );

                // 사용자가 취소를 누른 경우
                if (confirmed != true) {
                  print('[PictureOption] 사용자가 삭제 취소');
                  return;
                }

                // ✅ Optimistic UI: 즉시 UI에서 제거
                print('[PictureOption] Optimistic UI: 즉시 이미지 제거 시작');

                // 1. Provider에서 optimistic하게 제거
                if (matchedImageIds.isNotEmpty) {
                  ref
                      .read(matchedTripImagesProvider.notifier)
                      .optimisticRemove(matchedImageIds);
                  ref
                      .read(unmatchedTripImagesProvider.notifier)
                      .optimisticRemove(matchedImageIds);
                }
                if (pendingImageIds.isNotEmpty) {
                  ref
                      .read(pendingDayTripImagesProvider.notifier)
                      .optimisticRemove(pendingImageIds);
                }

                // 2. 맵 마커도 즉시 제거
                if (matchedImageIds.isNotEmpty) {
                  final endTripMapState =
                      context.findAncestorStateOfType<EndTripMapScreenState>();
                  await endTripMapState?.removeImageMarkers(matchedImageIds);
                }

                // 3. selection mode 즉시 해제 (UI가 이미 업데이트됨)
                ref.read(selectionModeProvider.notifier).state = false;

                // 4. 성공 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('사진이 삭제되었습니다.'),
                    backgroundColor: const Color.fromARGB(212, 56, 212, 121),
                  ),
                );

                // 5. 백그라운드에서 실제 삭제 API 호출
                try {
                  bool success = true;

                  // matched/unmatched 이미지 삭제
                  if (matchedImageIds.isNotEmpty) {
                    print('[PictureOption] 백그라운드: matched/unmatched 삭제 API 호출');
                    final matchedSuccess = await ref
                        .read(matchedTripImageRepository)
                        .deleteImages(
                          tripId: tripId,
                          imageIds: matchedImageIds,
                          urls: matchedUrls,
                        );
                    print(
                      '[PictureOption] matched/unmatched 삭제 결과: $matchedSuccess',
                    );
                    success = success && matchedSuccess;
                  }

                  // pending 이미지 삭제
                  if (pendingImageIds.isNotEmpty) {
                    print('[PictureOption] 백그라운드: pending 삭제 API 호출');
                    final tripDayPlaceIds =
                        pending
                            .map((img) => img.tripDayPlaceId)
                            .where((id) => id != null)
                            .cast<String>()
                            .toSet()
                            .toList();

                    for (final tripDayPlaceId in tripDayPlaceIds) {
                      final pendingSuccess = await ref
                          .read(pendingDayTripImagesProvider.notifier)
                          .deleteImages(
                            tripId: tripId,
                            tempPlaceImageId: tripDayPlaceId,
                            imageIds: pendingImageIds,
                            urls: pendingUrls,
                          );
                      print('[PictureOption] pending 삭제 결과: $pendingSuccess');
                      success = success && pendingSuccess;
                    }
                  }

                  // 6. 실패 시 롤백
                  if (!success) {
                    print('[PictureOption] API 삭제 실패, 롤백 시작');
                    ref.invalidate(matchedTripImagesProvider);
                    ref.invalidate(unmatchedTripImagesProvider);
                    ref.invalidate(pendingDayTripImagesProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('사진 삭제에 실패했습니다. 다시 시도해주세요.')),
                    );
                  }
                } catch (e, st) {
                  print('[PictureOption] API 호출 중 예외 발생: $e\n$st');
                  // 롤백: provider refresh로 서버 데이터 다시 불러오기
                  ref.invalidate(matchedTripImagesProvider);
                  ref.invalidate(unmatchedTripImagesProvider);
                  ref.invalidate(pendingDayTripImagesProvider);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('오류: $e')));
                }
              }, // 삭제 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'asset/icon/delete.svg',
                    height: 32.h,
                    width: 32.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '삭제',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 11.sp,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              onPressed: () async {
                final tripState = ref.read(tripProvider).valueOrNull;
                if (tripState is! TripModel) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('여행 정보를 불러오는 중입니다. 다시 시도해주세요.'),
                    ),
                  );
                  return;
                }

                if (matchedOrUnmatched.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('즐겨찾기할 사진을 선택하세요.')),
                  );
                  return;
                }

                final repo = ref.read(tripImageRepositoryProvider);
                bool hasError = false;

                for (final image in matchedOrUnmatched) {
                  final tripDayPlaceId = image.tripDayPlaceId;
                  if (tripDayPlaceId == null) {
                    continue;
                  }
                  final newFavorite = !image.favorite;

                  if (image.type == GalleryImageType.matched) {
                    ref
                        .read(matchedTripImagesProvider.notifier)
                        .updateFavorite(image.id, newFavorite);
                  } else {
                    ref
                        .read(unmatchedTripImagesProvider.notifier)
                        .updateFavorite(image.id, newFavorite);
                  }

                  try {
                    await repo.updateFavorite(
                      tripId: tripState.tripId,
                      tripDayPlaceId: tripDayPlaceId,
                      imageId: image.id,
                      placeId: image.placeId,
                      favorite: newFavorite,
                    );
                  } catch (e) {
                    hasError = true;
                    break;
                  }
                }

                if (hasError) {
                  ref.invalidate(matchedTripImagesProvider);
                  ref.invalidate(unmatchedTripImagesProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('즐겨찾기 변경에 실패했습니다. 다시 시도해주세요.'),
                      backgroundColor: Color.fromARGB(229, 226, 81, 65),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('즐겨찾기 상태가 변경되었습니다.'),
                      backgroundColor: Color.fromARGB(212, 56, 212, 121),
                    ),
                  );
                }
                ref.read(selectionModeProvider.notifier).state = false;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'asset/icon/favorite.svg',
                    height: 32.h,
                    width: 32.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '즐겨찾기',
                    style: TextStyle(
                      color: const Color(0xffc6c6c6),
                      fontSize: 11.sp,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              onPressed: () async {
                final urls = [...matchedUrls, ...pendingUrls];
                if (!context.mounted) return;

                // URL만 공유하려면:
                // await shareImageUrls(urls);

                // 실제 파일 공유하려면:
                await shareImageFiles(urls, context, anchorContext: context);
                ref.read(selectionModeProvider.notifier).state = false;
              }, // 공유 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'asset/icon/share.svg',
                    height: 32.h,
                    width: 32.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '공유',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 11.sp,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              onPressed: () async {
                // matchedOrUnmatched["urls"]와 pending["urls"]를 합침
                final urls = [...matchedUrls, ...pendingUrls];
                await saveImagesToGallery(urls, context);
                ref.read(selectionModeProvider.notifier).state = false;
              }, // 저장 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'asset/icon/download.svg',
                    height: 32.h,
                    width: 32.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '내 갤러리에 저장',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 11.sp,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmScheduleState extends ConsumerWidget {
  final int tripId;
  final int lastDay;
  const ConfirmScheduleState({
    super.key,
    required this.tripId,
    required this.lastDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(width: 6.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8287FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
              minimumSize: Size.fromHeight(46.h),
              padding: EdgeInsets.zero,
            ),
            onPressed: () async {
              final scaffoldContext = context;
              final confirm = await showDialog<bool>(
                context: scaffoldContext,
                builder:
                    (context) => Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      insetPadding: EdgeInsets.all(14.w),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 12.w,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF8287FF),
                              size: 36.w,
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              '정말 여행 일정을 확정하시겠습니까?',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff313131),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffc6c6c6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 0,
                                      minimumSize: Size.fromHeight(46.h),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8287FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 0,
                                      minimumSize: Size.fromHeight(46.h),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      '확정',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              );
              if (confirm != true) return;

              bool success = false;
              String? errorMsg;
              try {
                final notifier = ref.read(confirmScheduleProvider.notifier);
                success = await notifier.confirmAndRefreshTrip(
                  tripId: tripId,
                  lastDay: lastDay,
                  ref: ref,
                );
              } catch (e) {
                success = false;
                if (e is Exception && e.toString().contains('Exception:')) {
                  errorMsg = e.toString().replaceFirst('Exception:', '').trim();
                } else {
                  errorMsg = e.toString();
                }
              }
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder:
                      (context) => Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        insetPadding: EdgeInsets.all(14.w),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 12.w,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                success
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color:
                                    success
                                        ? const Color(0xFF8287FF)
                                        : Colors.red,
                                size: 36.w,
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                success
                                    ? '여행 일정이 확정되었습니다!'
                                    : '일정 확정에 실패했습니다${errorMsg != null ? "\n$errorMsg" : ""}',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff313131),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        success
                                            ? const Color(0xFF8287FF)
                                            : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                    minimumSize: Size.fromHeight(46.h),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    '확인',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              }
            },
            child: Text(
              '여행 일정 확정하기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 6.w),
      ],
    );
  }
}

class ConfirmCalendarState extends StatelessWidget {
  const ConfirmCalendarState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 6.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8287FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
              minimumSize: Size.fromHeight(46.h),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 날짜 지정 화면으로 이동
              GoRouter.of(context).push('/W2mConfirmScreen');
            },
            child: Text(
              '여행 날짜 확정하기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 6.w),
      ],
    );
  }
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// TODO: 사진 저장하는 함수
Future<void> saveImagesToGallery(
  List<String> urls,
  BuildContext context,
) async {
  if (urls.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('저장할 이미지를 선택하세요.')));
    return;
  }

  bool dialogOpened = false;
  if (context.mounted) {
    dialogOpened = true;
    _showBlockingLoadingDialog(context);
  }

  int successCount = 0;
  for (final url in urls) {
    try {
      print('다운로드 시도: $url');
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final Uint8List imageBytes = Uint8List.fromList(response.data);
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: "yeogiga_${DateTime.now().millisecondsSinceEpoch}",
      );
      print('저장 결과: $result');
      if (result['isSuccess'] == true || result['isSuccess'] == null) {
        successCount++;
      }
    } catch (_) {}
  }

  if (dialogOpened && context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$successCount개의 사진이 갤러리에 저장되었습니다.'),
        backgroundColor: const Color.fromARGB(212, 56, 212, 121),
      ),
    );
  }
}

// TODO: 사진 공유하는 함수 (url을 텍스트로 공유)
Future<void> shareImageUrls(List<String> urls) async {
  if (urls.isEmpty) return;
  final text = urls.join('\n');
  Share.share(text, subject: '여행 사진 공유');
}

// TODO: 사진 공유하는 함수 (이미지를 공유)

Future<void> shareImageFiles(
  List<String> urls,
  BuildContext context, {
  BuildContext? anchorContext,
}) async {
  if (urls.isEmpty) return;

  bool dialogOpened = false;
  if (context.mounted) {
    dialogOpened = true;
    _showBlockingLoadingDialog(context);
  }

  try {
    final tempDir = await getTemporaryDirectory();
    List<XFile> files = [];

    for (final url in urls) {
      try {
        final response = await Dio().get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final fileName = url.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.data);
        files.add(XFile(file.path));
      } catch (e) {
        print('이미지 다운로드 실패: $e');
      }
    }

    if (dialogOpened && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (files.isNotEmpty) {
      final origin = _resolveShareOrigin(
        anchorContext ?? context,
        fallbackContext: context,
      );
      await Share.shareXFiles(
        files,
        text: '여행 사진 공유',
        sharePositionOrigin: origin,
      );
    }
  } catch (e) {
    if (dialogOpened && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

Rect _resolveShareOrigin(
  BuildContext context, {
  BuildContext? fallbackContext,
}) {
  RenderBox? box;
  try {
    box = context.findRenderObject() as RenderBox?;
  } catch (_) {}

  if (box != null && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }

  try {
    final overlayBox =
        Overlay.of(context, rootOverlay: true)?.context.findRenderObject()
            as RenderBox?;
    if (overlayBox != null && overlayBox.hasSize) {
      return overlayBox.localToGlobal(Offset.zero) & overlayBox.size;
    }
  } catch (_) {}

  if (fallbackContext != null && fallbackContext != context) {
    return _resolveShareOrigin(fallbackContext);
  }

  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final double width = logicalSize.width > 0 ? logicalSize.width : 1;
  final double height = logicalSize.height > 0 ? logicalSize.height : 1;
  return Rect.fromLTWH(0, 0, width, height);
}

void _showAddNoticeModal(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final titleTextController = TextEditingController();
      final contentTextController = TextEditingController();

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 340.w,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: 24),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        '공지하기',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: Color(0xff313131),
                        ),
                      ),
                      Text(
                        '팀원들에게 공지를 보낼 수 있어요',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: Color(0xff7d7d7d),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      //TODO: 제목 작성 필드
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xfff0f0f0),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextField(
                          controller: titleTextController,
                          maxLength: 20,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '제목을 작성해주세요',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              height: 1.4,
                              letterSpacing: -0.3,
                              color: Color(0xffc6c6c6),
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 19.h,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.4,
                            letterSpacing: -0.3,
                            color: Color(0xff313131),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      //TODO: 내용 작성 필드
                      Container(
                        height: 146.h,
                        decoration: BoxDecoration(
                          color: Color(0xfff0f0f0),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextField(
                          controller: contentTextController,
                          maxLength: 100,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '공지사항을 작성해주세요',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              height: 1.4,
                              letterSpacing: -0.3,
                              color: Color(0xffc6c6c6),
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 19.h,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.4,
                            letterSpacing: -0.3,
                            color: Color(0xff313131),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${contentTextController.text.length}/100',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            letterSpacing: -0.3,
                            color: Color(0xffc6c6c6),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 120.w,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed:
                                titleTextController.text.trim().isEmpty ||
                                        contentTextController.text
                                            .trim()
                                            .isEmpty
                                    ? null
                                    : () async {
                                      final title =
                                          titleTextController.text.trim();
                                      final content =
                                          contentTextController.text.trim();

                                      final tripState =
                                          ref.read(tripProvider).valueOrNull;
                                      if (tripState is TripModel) {
                                        final result = await ref
                                            .read(noticeListProvider.notifier)
                                            .createNotice(
                                              tripId: tripState.tripId,
                                              title: title,
                                              description: content,
                                            );

                                        if (result['success']) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '공지사항이 성공적으로 등록되었습니다.',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('공지사항 등록에 실패했습니다.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        GoRouter.of(context).pop();
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff8287ff),
                              disabledBackgroundColor: Color(0xffc6c6c6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              '확인',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                height: 1.4,
                                letterSpacing: -0.3,
                                color: Color(0xffffffff),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// 업로드 로딩 다이얼로그
class _UploadingDialog extends StatelessWidget {
  const _UploadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ 안드로이드 뒤로가기 버튼 막기
    return WillPopScope(
      onWillPop: () async => false, // false를 반환하면 뒤로가기 무시
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 로딩 인디케이터
              SizedBox(
                width: 50.w,
                height: 50.h,
                child: CircularProgressIndicator(
                  strokeWidth: 4.w,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff8287ff)),
                ),
              ),
              SizedBox(height: 20.h),
              // 텍스트
              Text(
                '사진 업로드 중...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff8287ff),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '잠시만 기다려주세요',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
