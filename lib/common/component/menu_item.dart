import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class MenuItem extends StatelessWidget {
  final String svgAsset;
  final String text;
  final VoidCallback? onTap;

  const MenuItem({
    super.key,
    required this.svgAsset,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 64.h,
          child: Row(
            children: [
              SizedBox(width: 20.w),
              SvgPicture.asset(svgAsset, width: 24.w, height: 24.h),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16.sp,
                  height: 1.40,
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
