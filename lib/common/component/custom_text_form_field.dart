import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomTextFormField({
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.obscureText = false,
    this.hintText,
    this.errorText,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xff8287ff), width: 1.0),
      borderRadius: BorderRadius.circular(12),
    );

    return TextFormField(
      controller: _controller,
      cursorColor: const Color(0xff8287ff),
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.0),
        fillColor: Colors.grey[200],
        filled: true,
        border: baseBorder,
        focusedBorder: baseBorder,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon:
            _controller.text.isNotEmpty
                ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!("");
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffc6c6c6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                )
                : null,
      ),
    );
  }
}
