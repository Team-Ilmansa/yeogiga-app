import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/trip/component/detail_screen/favorite_gallery/no_favorite_image.dart';
import 'package:yeogiga/trip/provider/gallery_images_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

class FavoriteGalleryTab extends ConsumerWidget {
  const FavoriteGalleryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteImages = ref.watch(favoriteGalleryImagesProvider);
    final trip = ref.watch(tripProvider).valueOrNull;
    final tripId = trip is TripModel ? trip.tripId : null;

    if (favoriteImages.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          SliverToBoxAdapter(
            child: SizedBox(height: 320.h, child: const NoFavoriteImage()),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 14.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${favoriteImages.length}장',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: const Color(0xff313131),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 4.h,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate((context, idx) {
              final image = favoriteImages[idx];
              return GestureDetector(
                onTap: () {
                  if (tripId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('여행 정보를 불러오는 중입니다. 다시 시도해주세요.'),
                      ),
                    );
                    return;
                  }
                  context.push(
                    '/tripImageView',
                    extra: {
                      'images': favoriteImages,
                      'initialIndex': idx,
                      'tripId': tripId,
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Container(color: Colors.grey[300]),
                  ),
                ),
              );
            }, childCount: favoriteImages.length),
          ),
        ),
      ],
    );
  }
}
