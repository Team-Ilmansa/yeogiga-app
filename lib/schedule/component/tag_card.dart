import 'package:flutter/material.dart';

class TagCard extends StatelessWidget {
  final String label;

  const TagCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Color(0xff7d7d7d), fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
