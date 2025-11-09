import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SimpleLoadingDialog extends StatelessWidget {
  final String message;

  const SimpleLoadingDialog({super.key, this.message = '잠시만 기다려주세요'});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xff8287ff),
                strokeWidth: 3,
              ),
              SizedBox(height: 24.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff222222),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
