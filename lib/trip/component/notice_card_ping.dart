import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoticeCardPing extends StatelessWidget {
  final String title;
  final String time;

  const NoticeCardPing({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffe6e7ff),
          borderRadius: BorderRadius.circular(14),
        ),
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SvgPicture.asset('asset/icon/ping.svg', width: 25, height: 25),
              const SizedBox(width: 8),
              Text(
                'Text',
                style: const TextStyle(
                  fontSize: 17,
                  letterSpacing: -0.3,
                  color: Color(0xff7d7d7d),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Time',
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: -0.3,
                    color: Color(0xff8287ff),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
