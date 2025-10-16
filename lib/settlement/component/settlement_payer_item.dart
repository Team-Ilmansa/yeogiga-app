import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';

class SettlementPayerItem extends StatelessWidget {
  final String name;
  final String? profileImageUrl;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isManualMode;
  final String? displayPrice;
  final TextEditingController? priceController;
  final Function(String)? onPriceChanged;
  final bool isMe;

  const SettlementPayerItem({
    super.key,
    required this.name,
    this.profileImageUrl,
    this.isSelected = false,
    this.onTap,
    this.isManualMode = false,
    this.displayPrice,
    this.priceController,
    this.onPriceChanged,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h, // 고정 높이 설정
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.sp,
            height: 28.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36.r),
              border: isMe ? Border.all(width: 0.889.sp, color: Color(0xff8287ff)) : null,
              image:
                  profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                profileImageUrl == null || profileImageUrl!.isEmpty
                    ? Icon(Icons.person, size: 16.sp, color: Color(0xff8287ff))
                    : null,
          ),
          SizedBox(width: 8.w),
          Text(
            isMe ? '(나) $name' : name,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
              letterSpacing: -0.36,
              color: Color(0xff313131),
            ),
          ),
          Spacer(),

          // 가격 표시 영역
          if (isSelected)
            SizedBox(
              width: 100.w,
              height: 36.h, // TextField와 동일한 높이
              child:
                  isManualMode
                      ? Align(
                        alignment: Alignment.center,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff313131),
                            height: 1.5,
                            letterSpacing: -0.36,
                          ),
                          decoration: InputDecoration(
                            hintText: '금액 작성하기',
                            hintStyle: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xffc6c6c6),
                              height: 1.5,
                              letterSpacing: -0.36,
                            ),
                            suffixText: ' 원',
                            suffixStyle: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff313131),
                              height: 1.5,
                              letterSpacing: -0.36,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 8.h,
                            ),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            // 콤마 제거 후 onPriceChanged 호출
                            if (onPriceChanged != null) {
                              final numericValue = value.replaceAll(',', '');
                              onPriceChanged!(numericValue);
                            }
                          },
                        ),
                      )
                      : Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            displayPrice ?? '0 원',
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.5,
                              letterSpacing: -0.36,
                              color: Color(0xff8287ff),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
            ),

          GestureDetector(
            onTap: onTap,
            child: SvgPicture.asset(
              isSelected
                  ? 'asset/icon/check_background.svg'
                  : 'asset/icon/grey check_background.svg',
              width: 20.sp,
              height: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
