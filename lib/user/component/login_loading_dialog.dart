import 'package:flutter/material.dart';
import 'package:yeogiga/common/component/simple_loading_dialog.dart';

class LoginLoadingDialog extends StatelessWidget {
  const LoginLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleLoadingDialog(message: '로그인 중...');
  }
}
