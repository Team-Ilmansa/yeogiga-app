import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// 숫자 3자리마다 콤마 찍는 formatter
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 콤마 제거
    String newText = newValue.text.replaceAll(',', '');

    // 숫자만 남기기
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 숫자로 파싱
    int? value = int.tryParse(newText);
    if (value == null) {
      return oldValue;
    }

    // 3자리마다 콤마 추가
    String formattedText = _formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

//TODO:ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final bool? enabled;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomTextFormField({
    this.onChanged,
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
      borderRadius: BorderRadius.circular(11.r),
    );

    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      cursorColor: const Color(0xff8287ff),
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        fillColor: Colors.grey[200],
        filled: true,
        border: baseBorder,
        focusedBorder: baseBorder,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(11.r),
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
                      vertical: 14.h,
                      horizontal: 14.w,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffc6c6c6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 11.sp),
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
    this.onChanged,
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
      borderRadius: BorderRadius.circular(11.r),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        fillColor: Colors.grey[200],
        filled: true,
        border: baseBorder,
        focusedBorder: baseBorder,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(11.r),
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

//TODO:ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

class CustomSettlementTextFormField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final bool? enabled;
  final bool obscureText;
  final bool autofocus;
  final bool numbersOnly;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final Widget? suffix;

  const CustomSettlementTextFormField({
    this.onChanged,
    this.controller,
    this.autofocus = false,
    this.obscureText = false,
    this.numbersOnly = false,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.suffix,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomSettlementTextFormField> createState() =>
      _CustomSettlementTextFormFieldState();
}

class _CustomSettlementTextFormFieldState
    extends State<CustomSettlementTextFormField> {
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
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(11.r),
    );

    return TextFormField(
      controller: _controller,
      style: TextStyle(
        color: Color(0xff313131),
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: -0.48,
      ),
      enabled: widget.enabled,
      cursorColor: const Color(0xff8287ff),
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      keyboardType:
          widget.numbersOnly ? TextInputType.number : TextInputType.text,
      inputFormatters:
          widget.numbersOnly
              ? [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ]
              : null,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 19.h),
        hintText: widget.hintText,
        errorText: widget.errorText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        fillColor: Colors.grey[200],
        filled: true,
        border: baseBorder,
        focusedBorder: baseBorder,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(11.r),
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
