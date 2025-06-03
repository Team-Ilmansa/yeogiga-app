import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';

class PendingPlaceCardSliderPanel extends StatelessWidget {
  final NaverPlaceItem? place;
  final String? imageUrl;
  final VoidCallback? onAddPressed;
  final String buttonText;

  const PendingPlaceCardSliderPanel({
    Key? key,
    required this.place,
    this.imageUrl,
    this.onAddPressed,
    this.buttonText = '일정에 추가하기',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24.r,
            spreadRadius: 2.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: 36.w,
          left: 36.w,
          top: 36.h,
          bottom: 100.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 333.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(36.r),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(36.r),
                  ),
                  child:
                      imageUrl != null && imageUrl!.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(36.r),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              width: 300.w,
                              height: 300.w,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.image,
                                    size: 64.sp,
                                    color: Colors.grey[300],
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.image,
                            size: 100.sp,
                            color: Colors.grey[300],
                          ),
                ),
                SizedBox(width: 48.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      place?.category ?? '',
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: const Color(0xFF7D7D7D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      place?.title ?? '',
                      style: TextStyle(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      place?.roadAddress ?? place?.address ?? '',
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: const Color(0xFF313131),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 54.h),
            SizedBox(
              width: double.infinity,
              height: 156.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C8AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36.r),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                onPressed: onAddPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: SvgPicture.asset(
                        'asset/icon/add_schedule.svg',
                        width: 72.w,
                        height: 72.h,
                      ),
                    ),
                    Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
