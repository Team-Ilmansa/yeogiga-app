import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class NoFavoriteImage extends StatelessWidget {
  const NoFavoriteImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'asset/icon/favorite off.svg',
          height: 50.h,
          width: 50.w,
          color: const Color(0xffc6c6c6),
        ),
        SizedBox(height: 7.h),
        Text(
          '즐겨찾기한 이미지가 없어요',
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xffc6c6c6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
