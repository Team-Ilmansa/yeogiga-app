import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TripNameDialog extends StatefulWidget {
  final TextEditingController nameController;
  final VoidCallback? onConfirm;

  const TripNameDialog({
    super.key,
    required this.nameController,
    this.onConfirm,
  });

  @override
  State<TripNameDialog> createState() => _TripNameDialogState();
}

class _TripNameDialogState extends State<TripNameDialog> {
  bool get _canConfirm => widget.nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //다이얼로그 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 1),
                      IconButton(
                        icon: const Icon(Icons.close, size: 28),
                        onPressed: () => GoRouter.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '여행 이름을 설정해주세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff313131),
                      letterSpacing: -0.4,
                      height: -0.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '추후 수정이 가능해요',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff7d7d7d),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            //텍스트 필드 부분
            Column(
              children: [
                TextField(
                  controller: widget.nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFf0f0f0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '여행 이름',
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  style: const TextStyle(fontSize: 20),
                  maxLength: 20,
                ),
              ],
            ),
            const SizedBox(height: 40),
            //버튼 부분
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 140,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: _canConfirm ? widget.onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8287ff),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
