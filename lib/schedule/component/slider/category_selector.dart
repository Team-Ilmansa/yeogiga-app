import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategorySelector extends StatefulWidget {
  final Function(int)? onCategoryChanged; // 콜백 함수 추가
  final int? initialSelectedIndex; // 초기값 설정 가능
  
  const CategorySelector({
    super.key,
    this.onCategoryChanged,
    this.initialSelectedIndex,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late final ValueNotifier<int> selectedIndexNotifier;

  @override
  void initState() {
    super.initState();
    selectedIndexNotifier = ValueNotifier<int>(
      widget.initialSelectedIndex ?? 1, // 초기값 설정
    );
  }

  /// 1: 관광지
  /// 2: 숙소
  /// 3: 식당
  /// 4: 기타

  @override
  void dispose() {
    selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            selectedIndexNotifier.value = 1;
            widget.onCategoryChanged?.call(1); // 상위로 알림
          },
          child: CategoryItem(
            index: 1,
            selectedIndexNotifier: selectedIndexNotifier,
            categoryName: '관광지',
            categoryIconAsset: 'asset/icon/category spot.svg',
            categoryGreyIconAsset: 'asset/icon/category grey spot.svg',
          ),
        ),
        GestureDetector(
          onTap: () {
            selectedIndexNotifier.value = 2;
            widget.onCategoryChanged?.call(2); // 상위로 알림
          },
          child: CategoryItem(
            index: 2,
            selectedIndexNotifier: selectedIndexNotifier,
            categoryName: '숙소',
            categoryIconAsset: 'asset/icon/category hotel.svg',
            categoryGreyIconAsset: 'asset/icon/category grey hotel.svg',
          ),
        ),
        GestureDetector(
          onTap: () {
            selectedIndexNotifier.value = 3;
            widget.onCategoryChanged?.call(3); // 상위로 알림
          },
          child: CategoryItem(
            index: 3,
            selectedIndexNotifier: selectedIndexNotifier,
            categoryName: '식사',
            categoryIconAsset: 'asset/icon/category restaurant.svg',
            categoryGreyIconAsset: 'asset/icon/category grey restaurant.svg',
          ),
        ),
        GestureDetector(
          onTap: () {
            selectedIndexNotifier.value = 4;
            widget.onCategoryChanged?.call(4); // 상위로 알림
          },
          child: CategoryItem(
            index: 4,
            selectedIndexNotifier: selectedIndexNotifier,
            categoryName: '기타',
            categoryIconAsset: 'asset/icon/category etc.svg',
            categoryGreyIconAsset: 'asset/icon/category grey etc.svg',
          ),
        ),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  final int index;
  final ValueNotifier<int> selectedIndexNotifier;
  final String categoryName;
  final String categoryIconAsset;
  final String categoryGreyIconAsset;

  const CategoryItem({
    super.key,
    required this.categoryName,
    required this.categoryIconAsset,
    required this.categoryGreyIconAsset,
    required this.selectedIndexNotifier,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          // ValueListenableBuilder로 해당 아이템만 rebuild
          ValueListenableBuilder<int>(
            valueListenable: selectedIndexNotifier,
            builder: (context, selectedIndex, child) {
              return index == selectedIndex
                  ? SvgPicture.asset(
                    categoryIconAsset,
                    width: 40.w,
                    height: 40.h,
                  )
                  : SvgPicture.asset(
                    categoryGreyIconAsset,
                    width: 40.w,
                    height: 40.h,
                  );
            },
          ),
          SizedBox(height: 2.h),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 10.sp,
              height: 1.4,
              letterSpacing: -0.3,
              color: Color(0xff7d7d7d),
            ),
          ),
        ],
      ),
    );
  }
}
