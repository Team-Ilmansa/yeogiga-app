import 'package:flutter/material.dart';

Widget buildProfileAvatarPlaceholder({
  required String nickname,
  required double size,
  double? fontSize,
  Color backgroundColor = const Color(0xffe5e7ff),
  Color textColor = const Color(0xff5a61f8),
  BorderRadiusGeometry? borderRadius,
  FontWeight fontWeight = FontWeight.w700,
  double letterSpacing = -0.3,
}) {
  final initial = nickname.isNotEmpty ? nickname.substring(0, 1) : '?';
  final resolvedFontSize = fontSize ?? (size * 0.45);
  final resolvedRadius = borderRadius ?? BorderRadius.circular(size / 2);

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: resolvedRadius,
    ),
    alignment: Alignment.center,
    child: Text(
      initial,
      style: TextStyle(
        color: textColor,
        fontWeight: fontWeight,
        fontSize: resolvedFontSize,
        letterSpacing: letterSpacing,
      ),
    ),
  );
}
