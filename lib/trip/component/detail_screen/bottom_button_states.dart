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
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/trip_map/end/end_trip_map.dart';
import 'package:yeogiga/trip/view/trip_detail_screen.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';
import 'package:yeogiga/trip_image/repository/pending_trip_image_repository.dart';
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

class AddNoticeState extends StatelessWidget {
  const AddNoticeState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Color(0xff8287ff),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(42.r),
        //       ),
        //       minimumSize: Size.fromHeight(156.h),
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
        //           width: 72.w,
        //           height: 72.h,
        //         ),
        //         SizedBox(width: 30.w),
        //         Text(
        //           '일정 추가하기',
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 48.sp,
        //             fontWeight: FontWeight.w600,
        //             letterSpacing: -0.3,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // SizedBox(width: 36.w),
        SizedBox(width: 40.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8287ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              minimumSize: Size.fromHeight(156.h),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 공지 추가 액션
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/gong_ji.svg',
                  width: 72.w,
                  height: 72.h,
                ),
                SizedBox(width: 30.w),
                Text(
                  '공지 추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 160.h,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              // 사진 업로드 버튼
              Row(
                children: [
                  SizedBox(width: 40.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8287ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42.r),
                        ),
                        minimumSize: Size.fromHeight(156.h),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        if (widget.selectedDayIndex == 0) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('날짜를 선택해주세요')));
                          return;
                        }

                        final tripState = ref.read(tripProvider);
                        final tripId = (tripState as dynamic).tripId;

                        // 완료된 여행이라면?
                        if (tripState is CompletedTripModel) {
                          final completed = ref.watch(
                            completedScheduleProvider,
                          );

                          final match = completed!.data.firstWhere(
                            (e) => e.day == widget.selectedDayIndex,
                          );
                          print('[ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ] $match');
                          tripDayPlaceId = match.id;

                          // 진행중인 여행이라면?
                        } else if (tripState is InProgressTripModel) {
                          final confirmed = ref.watch(confirmScheduleProvider);
                          if (confirmed != null &&
                              confirmed.schedules.isNotEmpty) {
                            final match = confirmed.schedules.firstWhere(
                              (e) => e.day == widget.selectedDayIndex,
                            );
                            tripDayPlaceId = match.id;
                          }
                        }

                        if (await requestImagePermission()) {
                        } else {
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

                        final success = await notifier.uploadImages(
                          tripId: tripId,
                          tripDayPlaceId: tripDayPlaceId,
                          images: files,
                        );

                        if (success) {
                          //TODO: 개중요
                          final detailScreenState =
                              context
                                  .findAncestorStateOfType<
                                    TripDetailScreenState
                                  >();
                          await detailScreenState?.refreshAll();
                          final endTripMapState =
                              context
                                  .findAncestorStateOfType<
                                    EndTripMapScreenState
                                  >();
                          await endTripMapState?.refreshAll();
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
                            width: 72.w,
                            height: 72.h,
                          ),
                          SizedBox(width: 30.w),
                          Text(
                            widget.selectedDayIndex == 0
                                ? '날짜를 선택해주세요'
                                : '${widget.selectedDayIndex}일 차 사진 업로드하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 40.sp),
                ],
              ),
              // 사진 매핑/리매핑 버튼 (두 개를 Row로 묶어서 한 페이지에)
              Row(
                children: [
                  Icon(Icons.chevron_left, size: 40.sp),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8287ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42.r),
                        ),
                        minimumSize: Size.fromHeight(156.h),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        List<String> tripDayPlaceIds = [];
                        // TODO: 사진 매핑 api 호출
                        final tripState = ref.read(tripProvider);
                        final tripId = (tripState as dynamic).tripId;

                        // 완료된 여행이라면?
                        if (tripState is CompletedTripModel) {
                          final completed = ref.watch(
                            completedScheduleProvider,
                          );

                          tripDayPlaceIds =
                              completed!.data.map((e) => e.id).toList();

                          // 진행중인 여행이라면?
                        } else if (tripState is InProgressTripModel) {
                          final confirmed = ref.watch(confirmScheduleProvider);
                          tripDayPlaceIds =
                              confirmed!.schedules.map((e) => e.id).toList();
                        }

                        final notifier = ref.read(
                          pendingDayTripImagesProvider.notifier,
                        );
                        try {
                          final success = await notifier.assignImages(
                            tripId: tripId,
                            tripDayPlaceIds: tripDayPlaceIds,
                          );

                          if (success) {
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('사진 매핑 실패. 다시 시도해 주세요.')),
                            );
                          }
                        } catch (e, st) {
                          print('사진 매핑 중 예외 발생: $e\n$st');
                          // ScaffoldMessenger.of(
                          //   context,
                          // ).showSnackBar(SnackBar(content: Text('$e')));
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
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '사진 맵핑하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 36.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8287ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42.r),
                        ),
                        minimumSize: Size.fromHeight(156.h),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        // TODO: 사진 리매핑 api 호출
                        List<String> tripDayPlaceIds = [];
                        final tripState = ref.read(tripProvider);
                        final tripId = (tripState as dynamic).tripId;

                        // 완료된 여행이라면?
                        if (tripState is CompletedTripModel) {
                          final completed = ref.watch(
                            completedScheduleProvider,
                          );

                          tripDayPlaceIds =
                              completed!.data.map((e) => e.id).toList();

                          // 진행중인 여행이라면?
                        } else if (tripState is InProgressTripModel) {
                          final confirmed = ref.watch(confirmScheduleProvider);
                          tripDayPlaceIds =
                              confirmed!.schedules.map((e) => e.id).toList();
                        }

                        final notifier = ref.read(
                          matchedTripImagesProvider.notifier,
                        );

                        try {
                          final success = await notifier.reassignImagesToPlaces(
                            tripId: tripId,
                            tripDayPlaceIds: tripDayPlaceIds,
                          );

                          if (success) {
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('사진 리매핑 실패. 다시 시도해 주세요.')),
                            );
                          }
                        } catch (e, st) {
                          print('사진 리매핑 중 예외 발생: $e\n$st');
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
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ],
          ),
        ),
        // SizedBox(height: 18.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: List.generate(
        //     2,
        //     (idx) => Container(
        //       width: 18.w,
        //       height: 18.w,
        //       margin: EdgeInsets.symmetric(horizontal: 6.w),
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color:
        //             _currentPage == idx ? Color(0xff8287ff) : Color(0xffe0e0e0),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class PictureOptionState extends ConsumerWidget {
  final int selectedDayIndex;
  final Map<String, List<String>> matchedOrUnmatchedPayload;
  final Map<String, List<String>> pendingPayload;

  PictureOptionState({
    super.key,
    required this.selectedDayIndex,
    required this.matchedOrUnmatchedPayload,
    required this.pendingPayload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.translate(
      offset: const Offset(0, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () async {
                final tripState = ref.read(tripProvider);
                final tripId = (tripState as TripModel).tripId;

                final imageIds = matchedOrUnmatchedPayload["imageIds"] ?? [];
                final urls = matchedOrUnmatchedPayload["urls"] ?? [];

                if (imageIds.isEmpty || urls.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('삭제할 사진을 선택하세요.')));
                  return;
                }

                try {
                  final success = await ref
                      .read(matchedTripImageRepository)
                      .deleteImages(
                        tripId: tripId,
                        imageIds: imageIds,
                        urls: urls,
                      );
                  if (success) {
                    // TODO: 존나 중요
                    final detailScreenState =
                        context
                            .findAncestorStateOfType<TripDetailScreenState>();
                    await detailScreenState?.refreshAll();
                    final endTripMapState =
                        context
                            .findAncestorStateOfType<EndTripMapScreenState>();
                    await endTripMapState?.refreshAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('사진이 삭제되었습니다.'),
                        backgroundColor: const Color.fromARGB(
                          212,
                          56,
                          212,
                          121,
                        ),
                      ),
                    );
                    // 필요하다면 상태 갱신/선택 해제 등 추가
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('사진 삭제에 실패했습니다.')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$e')));
                }
              }, // 삭제 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/delete.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '삭제',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
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
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () async {
                final urls = [
                  ...?matchedOrUnmatchedPayload["urls"],
                  ...?pendingPayload["urls"],
                ];
                // URL만 공유하려면:
                // shareImageUrls(urls);

                // 실제 파일 공유하려면:
                await shareImageFiles(urls);
              }, // 공유 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/share.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '공유',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
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
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () async {
                // matchedOrUnmatched["urls"]와 pending["urls"]를 합침
                final urls = [
                  ...?matchedOrUnmatchedPayload["urls"],
                  ...?pendingPayload["urls"],
                ];
                await saveImagesToGallery(urls, context);
              }, // 저장 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/download.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '내 갤러리에 저장',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
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
        SizedBox(width: 40.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8287FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              elevation: 0,
              minimumSize: Size.fromHeight(156.h),
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
                        borderRadius: BorderRadius.circular(48.r),
                      ),
                      insetPadding: EdgeInsets.all(48.w),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 40.h,
                          horizontal: 40.w,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF8287FF),
                              size: 120.w,
                            ),
                            SizedBox(height: 48.h),
                            Text(
                              '정말 여행 일정을 확정하시겠습니까?',
                              style: TextStyle(
                                fontSize: 56.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff313131),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 50.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffc6c6c6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          42.r,
                                        ),
                                      ),
                                      elevation: 0,
                                      minimumSize: Size.fromHeight(156.h),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 48.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 32.w),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8287FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          42.r,
                                        ),
                                      ),
                                      elevation: 0,
                                      minimumSize: Size.fromHeight(156.h),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      '확정',
                                      style: TextStyle(
                                        fontSize: 48.sp,
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
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                        insetPadding: EdgeInsets.all(48.w),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 40.h,
                            horizontal: 40.w,
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
                                size: 120.w,
                              ),
                              SizedBox(height: 48.h),
                              Text(
                                success
                                    ? '여행 일정이 확정되었습니다!'
                                    : '일정 확정에 실패했습니다${errorMsg != null ? "\n$errorMsg" : ""}',
                                style: TextStyle(
                                  fontSize: 56.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff313131),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 50.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        success
                                            ? const Color(0xFF8287FF)
                                            : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(42.r),
                                    ),
                                    elevation: 0,
                                    minimumSize: Size.fromHeight(156.h),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    '확인',
                                    style: TextStyle(
                                      fontSize: 48.sp,
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
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w),
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
        SizedBox(width: 40.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8287FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              elevation: 0,
              minimumSize: Size.fromHeight(156.h),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 날짜 지정 화면으로 이동
              GoRouter.of(context).push('/W2mConfirmScreen');
            },
            child: Text(
              '여행 날짜 확정하기',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w),
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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$successCount개의 사진이 갤러리에 저장되었습니다.'),
      backgroundColor: const Color.fromARGB(212, 56, 212, 121),
    ),
  );
}

// TODO: 사진 공유하는 함수 (url을 텍스트로 공유)
void shareImageUrls(List<String> urls) {
  if (urls.isEmpty) return;
  final text = urls.join('\n');
  Share.share(text, subject: '여행 사진 공유');
}

// TODO: 사진 공유하는 함수 (이미지를 공유)

Future<void> shareImageFiles(List<String> urls) async {
  if (urls.isEmpty) return;
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

  if (files.isNotEmpty) {
    await Share.shareXFiles(files, text: '여행 사진 공유');
  }
}
