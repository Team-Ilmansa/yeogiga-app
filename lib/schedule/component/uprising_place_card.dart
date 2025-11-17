import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/model/uprising_place_model.dart';
import 'package:yeogiga/common/provider/uprising_place_provider.dart';

class UprisingCardGridList extends ConsumerWidget {
  const UprisingCardGridList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uprisingPlacesAsync = ref.watch(uprisingPlaceProvider);

    return uprisingPlacesAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return SizedBox(
            height: 267.h,
            child: Center(
              child: Text(
                '급상승 여행지가 없습니다.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
          );
        }

        return SizedBox(
          height: 267.h,
          child: GridView.builder(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 11.w,
              crossAxisSpacing: 11.w,
              childAspectRatio: 1,
            ),
            itemCount: places.length,
            itemBuilder: (_, i) => UprisingPlaceCard(place: places[i]),
          ),
        );
      },
      loading:
          () => SizedBox(
            height: 267.h,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xff8287ff)),
            ),
          ),
      error:
          (error, _) => SizedBox(
            height: 267.h,
            child: Center(
              child: Text(
                '급상승 여행지를 불러올 수 없습니다.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
          ),
    );
  }
}

class UprisingPlaceCard extends StatelessWidget {
  final UprisingPlaceModel place;

  const UprisingPlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 107.h,
        width: 107.w,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                place.url,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
              ),
            ),
            // 그라디언트 오버레이 (텍스트 가독성 향상)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // 여행지 이름 표시 (해시태그 스타일)
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '#${place.name.replaceAll(' ', '\n#')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
