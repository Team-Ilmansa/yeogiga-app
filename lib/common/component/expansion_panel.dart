import 'package:flutter/material.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';

class ExpansionPanel extends StatelessWidget {
  final String dayName;
  const ExpansionPanel({super.key, required this.dayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color.fromARGB(255, 221, 221, 221)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xffd9d9d9)),
        ),
        minTileHeight: 62,
        title: Text(
          dayName,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xff7d7d7d),
            letterSpacing: -0.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xff7d7d7d),
        ),
        children: const [
          ScheduleItem(title: 'Text', time: '11:00', done: true),
          ScheduleItem(title: 'Text', time: '11:00', done: false),
          ScheduleItem(title: 'Text', time: '11:00', done: false),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
