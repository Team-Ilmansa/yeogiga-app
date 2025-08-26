import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripNameDialog extends StatefulWidget {
  final TextEditingController nameController;
  final VoidCallback? onConfirm;

  const TripNameDialog({
    super.key,
    required this.nameController,
    this.onConfirm,
  });

  @override
  State<TripNameDialog> createState() => _TripNameDialogState();
}

class _TripNameDialogState extends State<TripNameDialog> {
  bool get _canConfirm => widget.nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21.r)),
      insetPadding: EdgeInsets.all(14.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //다이얼로그 헤더
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 1.w),
                      IconButton(
                        icon: Icon(Icons.close, size: 25.sp),
                        onPressed: () => GoRouter.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 9.h),
                  Text(
                    '여행 이름을 설정해주세요',
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff313131),
                      letterSpacing: -0.1,
                      height: -0.0,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    '추후 수정이 가능해요',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Color(0xff7d7d7d),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 23.h),
            //텍스트 필드 부분
            Column(
              children: [
                TextField(
                  controller: widget.nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFf0f0f0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '여행 이름',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize: 18.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 18.sp),
                  maxLength: 20,
                ),
              ],
            ),
            SizedBox(height: 36.h),
            //버튼 부분
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 125.w,
                  height: 58.h,
                  child: ElevatedButton(
                    onPressed: _canConfirm ? widget.onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8287ff),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
