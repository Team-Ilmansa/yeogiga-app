import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final bool? enabled;
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
    this.enabled = true,
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
      borderSide: const BorderSide(color: Color(0xff8287ff), width: 1),
      borderRadius: BorderRadius.circular(36.r),
    );

    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      cursorColor: const Color(0xff8287ff),
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 54.h),
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 42.sp),
        fillColor: Colors.grey[200],
        filled: true,
        border: baseBorder,
        focusedBorder: baseBorder,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(36.r),
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
                    margin: EdgeInsets.symmetric(
                      vertical: 48.h,
                      horizontal: 48.w,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffc6c6c6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 36.sp),
                  ),
                )
                : null,
      ),
    );
  }
}

//TODO:ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

class CustomVerifyTextFormField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final bool? enabled;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final Widget? suffix;

  const CustomVerifyTextFormField({
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.obscureText = false,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.suffix,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomVerifyTextFormField> createState() =>
      _CustomVerifyTextFormFieldState();
}

class _CustomVerifyTextFormFieldState extends State<CustomVerifyTextFormField> {
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
      borderSide: const BorderSide(color: Color(0xff8287ff), width: 1),
      borderRadius: BorderRadius.circular(36.r),
    );

    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      cursorColor: const Color(0xff8287ff),
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      inputFormatters: [
        LengthLimitingTextInputFormatter(6), // 최대 6글자 제한
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 54.h),
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 42.sp),
        fillColor: Colors.grey[200],
        filled: true,
        border: baseBorder,
        focusedBorder: baseBorder,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(36.r),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: widget.suffix,
      ),
    );
  }
}
