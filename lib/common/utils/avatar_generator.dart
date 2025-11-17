import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// 닉네임 기반 아바타 생성 유틸리티
class AvatarGenerator {
  /// 닉네임에서 앞 두 글자 추출
  static String getInitials(String nickname) {
    if (nickname.isEmpty) return '??';
    if (nickname.length == 1) return nickname;
    return nickname.substring(0, 2);
  }

  /// 닉네임 기반으로 고정된 랜덤 색상 생성
  static Color getColorFromNickname(String nickname) {
    // 닉네임의 해시코드를 시드로 사용하여 일관된 색상 생성
    final seed = nickname.hashCode;
    final random = Random(seed);

    // 밝고 선명한 색상 팔레트
    final colors = [
      const Color(0xFFFF6B6B), // 빨강
      const Color(0xFF4ECDC4), // 청록
      const Color(0xFFFFE66D), // 노랑
      const Color(0xFF95E1D3), // 민트
      const Color(0xFFFFA07A), // 연어색
      const Color(0xFF9B59B6), // 보라
      const Color(0xFF3498DB), // 파랑
      const Color(0xFFE74C3C), // 진한 빨강
      const Color(0xFF1ABC9C), // 청록2
      const Color(0xFFF39C12), // 오렌지
      const Color(0xFF8287FF), // 앱 메인 컬러
      const Color(0xFFFF85A2), // 핑크
      const Color(0xFF7ED6DF), // 하늘색
      const Color(0xFFE056FD), // 자주
      const Color(0xFF686DE0), // 남보라
    ];

    return colors[random.nextInt(colors.length)];
  }

  /// 닉네임 기반 아바타 이미지 생성 (Canvas 기반)
  static Future<File> generateAvatarImage(String nickname) async {
    final initials = getInitials(nickname);
    final backgroundColor = getColorFromNickname(nickname);

    // 이미지 크기 (고해상도)
    const size = 500.0;

    // Canvas로 직접 그리기
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

    // 원형 배경 그리기
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // 텍스트 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: const TextStyle(
          fontSize: 200,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    // Picture를 Image로 변환
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());

    // 임시 파일로 저장
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/avatar_${nickname.hashCode}.png');
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    await file.writeAsBytes(pngBytes);

    return file;
  }
}
