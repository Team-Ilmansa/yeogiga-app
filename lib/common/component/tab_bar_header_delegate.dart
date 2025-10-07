import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  TabBarHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: Colors.white, child: child);
  }

  @override
  double get maxExtent => 32.h; // TabBar의 실제 높이와 동일하게!

  @override
  double get minExtent => 32.h;

  @override
  bool shouldRebuild(covariant TabBarHeaderDelegate oldDelegate) => false;
}
