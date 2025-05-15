import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DaySelector({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = index == 0 ? '여행 전체' : 'DAY $index';

          return GestureDetector(
            onTap: () {
              onChanged(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xffd9d9d9)),
                color: isSelected ? const Color(0xff8287ff) : Colors.white,
              ),
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xff7d7d7d),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(label),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
