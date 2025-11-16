import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? asset;

  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (asset != null) ...[
              Center(
                child: SvgPicture.asset(asset!, height: 70.h, width: 70.w),
              ),
              SizedBox(height: 16.h),
            ],
            Center(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xff8287ff),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7D7D7D),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: -0.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
