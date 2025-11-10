import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/grey_bar.dart';
import 'package:yeogiga/common/component/menu_item.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/trip_image/view/move_trip_image_view.dart';

class TripImageMoreMenuSheet extends ConsumerWidget {
  final GalleryImage currentImage;
  final VoidCallback onImageDeleted;
  final Future<void> Function()? onMoveImageTap;

  const TripImageMoreMenuSheet({
    super.key,
    required this.currentImage,
    required this.onImageDeleted,
    this.onMoveImageTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMoveOption =
        currentImage.type != GalleryImageType.pending &&
        (
          (currentImage.type == GalleryImageType.matched &&
              currentImage.tripDayPlaceId != null &&
              currentImage.placeId != null) ||
          (currentImage.type == GalleryImageType.unmatched &&
              currentImage.tripDayPlaceId != null)
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GoRouter.of(context).pop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: showMoveOption ? 329.h : 284.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GreyBar(),
              MenuItem(
                svgAsset: 'asset/icon/menu/download_black.svg',
                text: '내 갤러리에 저장',
                onTap: () async {
                  // context 미리 캡처
                  final navigator = Navigator.of(context);

                  try {
                    await saveImagesToGallery([currentImage.url], context);
                  } finally {
                    // 바텀 시트 닫기
                    if (context.mounted) navigator.pop();
                  }
                },
              ),
              MenuItem(
                svgAsset: 'asset/icon/menu/share_edit.svg',
                text: '공유하기',
                onTap: () async {
                  // context 미리 캡처
                  final navigator = Navigator.of(context);

                  try {
                    if (!context.mounted) return;
                    await shareImageFiles(
                      [currentImage.url],
                      context,
                      anchorContext: navigator.context,
                    );
                  } finally {
                    // 바텀 시트 닫기
                    if (context.mounted) navigator.pop();
                  }
                },
              ),
              if (showMoveOption)
                MenuItem(
                  svgAsset: 'asset/icon/menu/spot_black.svg',
                  text: '위치 옮기기',
                  onTap: () async {
                    if (currentImage.type == GalleryImageType.matched &&
                        (currentImage.placeId == null ||
                            currentImage.tripDayPlaceId == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미지 정보가 올바르지 않습니다.')),
                      );
                      return;
                    }
                    if (currentImage.type == GalleryImageType.unmatched &&
                        currentImage.tripDayPlaceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미지 정보가 올바르지 않습니다.')),
                      );
                      return;
                    }
                    GoRouter.of(context).pop();
                    if (onMoveImageTap != null) {
                      await onMoveImageTap!();
                    } else {
                      if (!context.mounted) return;
                      await context.push(
                        '/moveTripImageView',
                        extra: MoveTripImageArgs(image: currentImage),
                      );
                    }
                  },
                ),
              MenuItem(
                svgAsset: 'asset/icon/menu/delete_edit.svg',
                text: '삭제하기',
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => ConfirmationDialog(
                          title: '사진 삭제하기',
                          content: '이 사진을 삭제하시겠습니까?\n삭제된 사진은 복구할 수 없습니다.',
                          cancelText: '취소',
                          confirmText: '삭제하기',
                          confirmColor: const Color(0xFFE25141),
                        ),
                  );

                  if (confirmed == true) {
                    if (!context.mounted) return;
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    // 바텀시트 닫기
                    GoRouter.of(context).pop();

                    try {
                      final tripState = ref.read(tripProvider).valueOrNull;
                      if (tripState is! TripModel) {
                        throw Exception('여행 정보를 불러올 수 없습니다.');
                      }
                      final tripId = tripState.tripId;
                      final imageId = currentImage.id;
                      final imageUrl = currentImage.url;

                      bool success = true;

                      if (currentImage.type == GalleryImageType.matched ||
                          currentImage.type == GalleryImageType.unmatched) {
                        if (currentImage.type == GalleryImageType.matched) {
                          ref
                              .read(matchedTripImagesProvider.notifier)
                              .optimisticRemove([imageId]);
                        } else {
                          ref
                              .read(unmatchedTripImagesProvider.notifier)
                              .optimisticRemove([imageId]);
                        }

                        final repo = ref.read(matchedTripImageRepository);
                        success = await repo.deleteImages(
                          tripId: tripId,
                          imageIds: [imageId],
                          urls: [imageUrl],
                        );

                        if (!success) {
                          ref.invalidate(matchedTripImagesProvider);
                          ref.invalidate(unmatchedTripImagesProvider);
                        }
                      } else if (
                          currentImage.type == GalleryImageType.pending) {
                        final tripDayPlaceId = currentImage.tripDayPlaceId;
                        if (tripDayPlaceId == null) {
                          throw Exception('임시 저장 이미지 정보가 올바르지 않습니다.');
                        }

                        final pendingNotifier =
                            ref.read(pendingDayTripImagesProvider.notifier);
                        pendingNotifier.optimisticRemove([imageId]);

                        success = await pendingNotifier.deleteImages(
                          tripId: tripId,
                          tempPlaceImageId: tripDayPlaceId,
                          imageIds: [imageId],
                          urls: [imageUrl],
                        );

                        if (!success) {
                          ref.invalidate(pendingDayTripImagesProvider);
                        }
                      }

                      if (!success) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '사진 삭제에 실패했습니다. 다시 시도해주세요.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: const Color(0xFFE25141),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(5.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      onImageDeleted();

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '사진이 삭제되었습니다.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: const Color.fromARGB(
                            212,
                            56,
                            212,
                            121,
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(5.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ref.invalidate(matchedTripImagesProvider);
                      ref.invalidate(unmatchedTripImagesProvider);
                      ref.invalidate(pendingDayTripImagesProvider);

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '사진 삭제에 실패했습니다.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: const Color.fromARGB(
                            229,
                            226,
                            81,
                            65,
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(5.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
