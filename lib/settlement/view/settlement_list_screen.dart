import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettlementListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'settlementListScreen';
  const SettlementListScreen({super.key});

  @override
  ConsumerState<SettlementListScreen> createState() =>
      _SettlementListScreenState();
}

class _SettlementListScreenState extends ConsumerState<SettlementListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 48.h,
        backgroundColor: Color(0xfffafafa),
        shadowColor: Colors.transparent, // 그림자도 제거
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}
