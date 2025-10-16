import 'package:flutter_riverpod/flutter_riverpod.dart';

// 갤러리 사진 선택모드 변경
final selectionModeProvider = StateProvider<bool>((ref) => false);

// 핑 찍을 위치 검색모드 변경
final pingSelectionModeProvider = StateProvider<bool>((ref) => false);

// ing 맵에서 마커 선택 시, 해당 위치 정보 패널 보여주기
final viewLocationDetailProvider = StateProvider<bool>((ref) => false);

// 정산 내역 수정하기 모드인지 아닌지 확인
final isSettlementUpdateModeProvider = StateProvider<bool>((ref) {
  ref.keepAlive(); // 자동 dispose 방지
  return false;
});
