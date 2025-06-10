import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class NoImage extends StatelessWidget {
  const NoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100.h),
        SvgPicture.asset(
          'asset/icon/no_picture.svg',
          height: 168.h,
          width: 168.w,
          color: const Color(0xffc6c6c6),
        ),
        SizedBox(height: 24.h),
        Text(
          '업로드된 이미지가 없어요',
          style: TextStyle(
            fontSize: 42.sp,
            color: const Color(0xffc6c6c6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
