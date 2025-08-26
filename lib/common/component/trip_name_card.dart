import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class TripNameCardByAsset extends StatelessWidget {
  final String assetUrl;
  final String name;
  final Color color;

  const TripNameCardByAsset({
    super.key,
    required this.assetUrl,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(assetUrl, width: 15.w, height: 15.h, color: color),
        SizedBox(width: 5.w),
        Text(
          name,
          style: TextStyle(color: color, fontSize: 12.sp, letterSpacing: -0.1),
        ),
      ],
    );
  }
}
