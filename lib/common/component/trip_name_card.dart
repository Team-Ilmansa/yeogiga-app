import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TripNameCardByAsset extends StatelessWidget {
  final String assetUrl;
  final String name;
  final Color color;

  const TripNameCardByAsset({
    super.key,
    required this.assetUrl,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(assetUrl, width: 17, height: 17, color: color),
        SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(color: color, fontSize: 14, letterSpacing: -0.3),
        ),
      ],
    );
  }
}
