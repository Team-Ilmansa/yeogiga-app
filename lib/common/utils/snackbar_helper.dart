import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _successSnackColor = Color(0xFF8287FF);
const _errorSnackColor = Color(0xFFE25141);

SnackBar buildAppSnackBar(
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
}) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    backgroundColor: isError ? _errorSnackColor : _successSnackColor,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(5.w),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.r),
    ),
    elevation: 0,
    duration: duration,
    action: action,
  );
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    buildAppSnackBar(
      message,
      isError: isError,
      duration: duration,
      action: action,
    ),
  );
}

extension AppSnackMessenger on ScaffoldMessengerState {
  void showAppSnack(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackBar(
      buildAppSnackBar(
        message,
        isError: isError,
        duration: duration,
        action: action,
      ),
    );
  }
}
