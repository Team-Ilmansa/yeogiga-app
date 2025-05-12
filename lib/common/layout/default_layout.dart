import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final Widget body;
  const DefaultLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body);
  }
}
