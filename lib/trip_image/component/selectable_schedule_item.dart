import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yeogiga/common/utils/category_icon_util.dart';

class SelectableScheduleItem extends StatelessWidget {
  final String title;
  final String category;
  final bool selected;
  final bool done;
  final VoidCallback onTap;

  const SelectableScheduleItem({
    super.key,
    required this.title,
    required this.category,
    required this.selected,
    required this.onTap,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcon = CategoryIconUtil.getCategoryIconByKorean(category);
    final baseBackground = Color(0xFFf0f0f0);
    final selectedBackground = const Color(0xFFE6E7FF);
    final textColor =
        selected ? const Color(0xFF8287FF) : const Color(0xFF7D7D7D);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 9.w),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 36.w,
              height: 53.h,
              child: Center(
                child: SvgPicture.asset(
                  categoryIcon,
                  width: 24.w,
                  height: 24.h,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 60.h,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: selected ? selectedBackground : baseBackground,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.w,
                      color:
                          selected
                              ? const Color(0xFF8287FF)
                              : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  // shadows:
                  //     selected
                  //         ? []
                  //         : [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.05),
                  //             blurRadius: 4,
                  //             offset: const Offset(0, 2),
                  //           ),
                  //         ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20.w,
                      top: 19.h,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                          letterSpacing: -0.48,
                        ),
                      ),
                    ),
                    if (done)
                      Positioned(
                        right: 16.w,
                        top: 16.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC6C6C6),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Text(
                            '완료',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
