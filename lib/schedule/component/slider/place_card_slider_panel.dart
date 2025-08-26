import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';

class PlaceCardSliderPanel extends StatelessWidget {
  final NaverPlaceItem? place;
  final String? imageUrl;
  final VoidCallback? onAddPressed;
  final String buttonText;

  const PlaceCardSliderPanel({
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
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 2.r,
            spreadRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: 11.w,
          left: 11.w,
          top: 11.h,
          bottom: 30.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 99.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 89.w,
                  height: 89.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child:
                      imageUrl != null && imageUrl!.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(11.r),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              width: 89.w,
                              height: 89.w,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.image,
                                    size: 19.sp,
                                    color: Colors.grey[300],
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.image,
                            size: 30.sp,
                            color: Colors.grey[300],
                          ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      place?.category ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF7D7D7D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      place?.title ?? '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      place?.roadAddress ?? place?.address ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF313131),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C8AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                onPressed: onAddPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.h),
                      child: SvgPicture.asset(
                        'asset/icon/add_schedule.svg',
                        width: 21.w,
                        height: 21.h,
                      ),
                    ),
                    Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.1,
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
