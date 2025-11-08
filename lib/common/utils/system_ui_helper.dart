import 'package:flutter/material.dart';

/// 시스템 네비게이션 바 타입에 따라 SafeArea의 bottom 값을 결정
///
/// - 버튼 네비게이션 (3-button): bottom padding ≥ 40 → true 반환
/// - 제스처 네비게이션 (Gesture): bottom padding < 40 → false 반환
///
/// 사용 예시:
/// ```dart
/// SafeArea(
///   bottom: shouldUseSafeAreaBottom(context),
///   child: YourWidget(),
/// )
/// ```
bool shouldUseSafeAreaBottom(BuildContext context) {
  final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
  // 24로 나누는게 가장 실용적
  return bottomPadding >= 35;
}
