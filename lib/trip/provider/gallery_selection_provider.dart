import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 갤러리 사진 선택 상태 관리 (matched/unmatched 이미지의 인덱스 Set)
final gallerySelectionProvider =
    StateNotifierProvider<GallerySelectionNotifier, Set<int>>((ref) {
  return GallerySelectionNotifier();
});

class GallerySelectionNotifier extends StateNotifier<Set<int>> {
  GallerySelectionNotifier() : super({});

  /// 사진 선택/해제 토글
  void toggle(int index) {
    print('[GallerySelection] toggle 호출: index=$index');
    print('[GallerySelection] 현재 state: $state');
    if (state.contains(index)) {
      print('[GallerySelection] 선택 해제: index=$index');
      state = {...state}..remove(index);
    } else {
      print('[GallerySelection] 선택 추가: index=$index');
      state = {...state, index};
    }
    print('[GallerySelection] 변경 후 state: $state');
  }

  /// 모든 선택 해제
  void clear() {
    print('[GallerySelection] clear 호출');
    print('[GallerySelection] 이전 state: $state');
    state = {};
    print('[GallerySelection] clear 후 state: $state');
  }

  /// 여러 사진 선택
  void addAll(Iterable<int> indices) {
    print('[GallerySelection] addAll 호출: indices=$indices');
    state = {...state, ...indices};
    print('[GallerySelection] addAll 후 state: $state');
  }

  /// 여러 사진 해제
  void removeAll(Iterable<int> indices) {
    print('[GallerySelection] removeAll 호출: indices=$indices');
    state = {...state}..removeAll(indices);
    print('[GallerySelection] removeAll 후 state: $state');
  }
}
