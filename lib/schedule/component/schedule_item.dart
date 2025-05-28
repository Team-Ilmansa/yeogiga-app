import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScheduleItem extends StatelessWidget {
  final String title;
  final String time;
  final bool done;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.time,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF0F0F0); // 모든 항목 동일 배경
    final textColor = const Color(0xFF7D7D7D);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/category icon.svg',
                  width: 26,
                  height: 26,
                ),
                Positioned(
                  bottom: 0,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  if (done)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      height: 31,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6C6C6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '완료',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItemList extends StatefulWidget {
  const ScheduleItemList({super.key});

  @override
  State<ScheduleItemList> createState() => _ScheduleItemListState();
}

class _ScheduleItemListState extends State<ScheduleItemList>
    with TickerProviderStateMixin {
  bool isExpanded = false;

  final List<Map<String, dynamic>> scheduleData = List.generate(
    30,
    (index) => {
      'title': 'Text',
      'time': '11:00',
      'done': index == 0 || index == 3,
    },
  );

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemHeight = 68.0;
    final totalItemCount = scheduleData.length;
    final minListHeight = itemHeight * 3.4;
    final listBottomPadding = 24.0;
    final maxExpandedHeight = 500.0;
    final totalListHeight = itemHeight * totalItemCount;
    final expandedHeight =
        totalListHeight + listBottomPadding < maxExpandedHeight
            ? totalListHeight + listBottomPadding
            : maxExpandedHeight;
    final calculatedHeight =
        isExpanded ? expandedHeight : minListHeight + listBottomPadding;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 0.3,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        "3월 25일 오늘의 일정",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff7d7d7d),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: calculatedHeight,
                    child: Stack(
                      children: [
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: totalItemCount,
                          itemBuilder: (context, index) {
                            final item = scheduleData[index];
                            return ScheduleItem(
                              title: item['title'],
                              time: item['time'],
                              done: item['done'],
                            );
                          },
                        ),
                        if (!isExpanded && totalItemCount > 4)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.6),
                                      Colors.white,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -25),
            child: ElevatedButton(
              onPressed: _toggleExpanded,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8287ff),
                shape: const StadiumBorder(),
                fixedSize: const Size(140, 45), // 고정 크기
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? "일정 접기" : "일정 펼치기",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
