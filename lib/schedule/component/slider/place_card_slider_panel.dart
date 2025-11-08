import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';
import 'package:yeogiga/schedule/component/slider/category_selector.dart';

class PlaceCardSliderPanel extends StatefulWidget {
  final NaverPlaceItem? place;
  final String? imageUrl;
  final Function(int selectedCategoryIndex)? onAddPressed; // 카테고리 index 전달
  final String buttonText;

  const PlaceCardSliderPanel({
    Key? key,
    required this.place,
    this.imageUrl,
    this.onAddPressed,
    this.buttonText = '일정에 추가하기',
  }) : super(key: key);

  @override
  State<PlaceCardSliderPanel> createState() => _PlaceCardSliderPanelState();
}

class _PlaceCardSliderPanelState extends State<PlaceCardSliderPanel> {
  int selectedCategoryIndex = 1; // 초기값: 관광지

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                width: 111.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFf0f0f0),
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // TODO: 나중에 만나자
          // SizedBox(
          //   height: 100.h,
          //   child: ListView.separated(
          //     primary: false,
          //     shrinkWrap: true,
          //     padding: EdgeInsets.symmetric(horizontal: 16.w),
          //     scrollDirection: Axis.horizontal,
          //     separatorBuilder: (context, index) => SizedBox(width: 8.w),
          //     itemCount: 5,
          //     itemBuilder: (context, index) {
          //       return Container(
          //         width: 100.w,
          //         height: 100.w,
          //         decoration: BoxDecoration(
          //           color: const Color(0xFFF4F4F4),
          //           borderRadius: BorderRadius.circular(11.r),
          //         ),
          //         child:
          //             widget.imageUrl != null && widget.imageUrl!.isNotEmpty
          //                 ? ClipRRect(
          //                   borderRadius: BorderRadius.circular(11.r),
          //                   child: Image.network(
          //                     widget.imageUrl!,
          //                     fit: BoxFit.cover,
          //                     width: 89.w,
          //                     height: 89.w,
          //                     errorBuilder:
          //                         (_, __, ___) => Icon(
          //                           Icons.image,
          //                           size: 19.sp,
          //                           color: Colors.grey[300],
          //                         ),
          //                   ),
          //                 )
          //                 : Icon(
          //                   Icons.image,
          //                   size: 30.sp,
          //                   color: Colors.grey[300],
          //                 ),
          //       );
          //     },
          //   ),
          // ),
          // SizedBox(height: 17.h),
          Padding(
            padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.place?.title ?? '',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF313131),
                    letterSpacing: -0.3,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.place?.roadAddress ?? widget.place?.address ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF7d7d7d),
                    letterSpacing: -0.3,
                    height: 1.4,
                  ),
                ),
                // Text(
                //   place?.category ?? '',
                //   style: TextStyle(
                //     fontSize: 11.sp,
                //     color: const Color(0xFF7D7D7D),
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
                SizedBox(height: 28.h),
                Text(
                  '카테고리를 선택해주세요',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.5,
                    letterSpacing: -0.3,
                    color: Color(0xff313131),
                  ),
                ),
                SizedBox(height: 8.h),
                CategorySelector(
                  initialSelectedIndex: selectedCategoryIndex,
                  onCategoryChanged: (index) {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                    print('선택된 카테고리: $index');
                  },
                ),
                SizedBox(height: 20.h),
                //목적지 추가 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C8AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      print(
                        '카테고리 $selectedCategoryIndex로 ${widget.place?.title} 추가',
                      );
                      widget.onAddPressed?.call(selectedCategoryIndex);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.h),
                          child: SvgPicture.asset(
                            'asset/icon/add_schedule.svg',
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                        Text(
                          widget.buttonText,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
