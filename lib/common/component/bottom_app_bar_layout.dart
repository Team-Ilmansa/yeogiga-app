import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공통 하단 바 레이아웃 컴포넌트
class BottomAppBarLayout extends ConsumerWidget {
  final Widget child;
  const BottomAppBarLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            offset: const Offset(0, 0),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(11.w, 11.h, 11.w, 22.h),
        child: child,
      ),
    );
  }
}
