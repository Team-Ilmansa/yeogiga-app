import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoticeCard extends StatelessWidget {
  final String title;

  const NoticeCard({super.key, required this.title});

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
              SvgPicture.asset('asset/icon/notice.svg', width: 25, height: 25),
              const SizedBox(width: 8),
              Text(
                'Text',
                style: const TextStyle(
                  fontSize: 17,
                  letterSpacing: -0.3,
                  color: Color(0xff7d7d7d),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
