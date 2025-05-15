import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yeogiga/user/view/home_screen.dart';

class ScreenWrapper extends StatefulWidget {
  const ScreenWrapper({super.key});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      // 중앙 FAB
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18), // 아래로 18px 이동
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () {
              print('중앙 버튼 눌림');
            },
            backgroundColor: const Color(0xFF8287FF),
            shape: const CircleBorder(),
            elevation: 0,
            child: const Icon(Icons.add, size: 40, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 곡선 하단 바
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomAppBar(
            elevation: 0, // Material 그림자 제거, 커스텀 그림자만 사용
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton(0, 'asset/icon/home.svg', '홈'),
                  const SizedBox(width: 80), // FAB와 동일한 공간 확보
                  _buildTabButton(1, 'asset/icon/user-02.svg', '마이페이지'),
                ],
              ),
            ),
          ),
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: const [HomeScreen(), Center(child: Text('마이페이지'))],
      ),
    );
  }

  // 하단 바 버튼 UI
  Widget _buildTabButton(int index, String assetPath, String title) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
            child: SvgPicture.asset(
              assetPath,
              width: 28,
              height: 28,
              color: isSelected ? const Color(0xFF8287FF) : Colors.grey,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: -0.3,
              color:
                  isSelected
                      ? const Color(0xFF8287FF)
                      : const Color(0xffc6c6c6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
