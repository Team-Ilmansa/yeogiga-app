import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/utils/profile_placeholder_util.dart';
import 'package:yeogiga/trip/model/trip_member_location.dart';

class MemberMarkerStyle {
  MemberMarkerStyle({
    double? avatarDiameter,
    double? pointerSize,
    double? horizontalInset,
    this.markerColor = const Color(0xff8287ff),
    this.shadowColor = const Color(0xff000000),
  })  : avatarDiameter = avatarDiameter ?? 48.w,
        pointerSize = pointerSize ?? 16.w,
        horizontalInset = horizontalInset ?? 8.w;

  final double avatarDiameter;
  final double pointerSize;
  final double horizontalInset;
  final Color markerColor;
  final Color shadowColor;

  double get width => avatarDiameter + horizontalInset;
  double get height => avatarDiameter + pointerSize;
  double get pointerTop => avatarDiameter - (pointerSize / 2);
}

class MemberMarkerWidget extends StatelessWidget {
  const MemberMarkerWidget({
    super.key,
    required this.member,
    this.style,
  });

  final TripMemberLocation member;
  final MemberMarkerStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? MemberMarkerStyle();
    return SizedBox(
      width: resolved.width,
      height: resolved.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: resolved.avatarDiameter,
              height: resolved.avatarDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: resolved.markerColor, width: 3.w),
                boxShadow: [
                  BoxShadow(
                    color: resolved.shadowColor.withOpacity(0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildProfileContent(
                  imageUrl: member.imageUrl,
                  nickname: member.nickname,
                  size: resolved.avatarDiameter,
                ),
              ),
            ),
          ),
          Positioned(
            top: resolved.pointerTop,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: resolved.pointerSize,
                height: resolved.pointerSize,
                decoration: BoxDecoration(
                  color: resolved.markerColor,
                  boxShadow: [
                    BoxShadow(
                      color: resolved.shadowColor.withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent({
    required String? imageUrl,
    required String nickname,
    required double size,
  }) {
    final fallback = buildProfileAvatarPlaceholder(
      nickname: nickname,
      size: size,
    );
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return fallback;
        },
      );
    }
    return fallback;
  }
}
