import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/day_selector.dart';

class GalleryTab extends StatefulWidget {
  final ValueChanged<bool>? onSelectionModeChanged;
  const GalleryTab({super.key, this.onSelectionModeChanged});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final List<String> days = List.generate(10, (index) => 'DAY ${index + 1}');
  int selectedDayIndex = 0;
  int numberOfPicture = 57;
  bool selectionMode = false;
  Set<int> selectedPictures = {};

  void setSelectionMode(bool value) {
    if (selectionMode != value) {
      setState(() {
        selectionMode = value;
      });
      widget.onSelectionModeChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 48.h)),
        SliverToBoxAdapter(
          child: DaySelector(
            itemCount: days.length + 1, // +1 for '여행 전체'
            selectedIndex: selectedDayIndex,
            onChanged: (index) {
              setState(() {
                selectedDayIndex = index;
                selectedPictures.clear();
                selectionMode = false;
              });
              widget.onSelectionModeChanged?.call(false);
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        //TODO: 그리드 뷰 부분 (사진 있으면)
        if (true)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$numberOfPicture장',
                          style: TextStyle(
                            fontSize: 60.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Color(0xff313131),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setSelectionMode(!selectionMode);
                            if (!selectionMode) {
                              setState(() {
                                selectedPictures.clear();
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                selectionMode
                                    ? '${selectedPictures.length}개 선택됨'
                                    : '선택하기',
                                style: TextStyle(
                                  fontSize: 39.sp,
                                  letterSpacing: -0.6,
                                  color:
                                      selectionMode
                                          ? Color(0xff8287ff)
                                          : Color.fromARGB(255, 193, 193, 193),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              SvgPicture.asset(
                                'asset/icon/check.svg',
                                width: 48.w,
                                height: 48.h,
                                color:
                                    selectionMode
                                        ? Color(0xff8287ff)
                                        : Color.fromARGB(255, 193, 193, 193),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 48.w),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: numberOfPicture,
                    itemBuilder: (context, idx) {
                      final isSelected = selectedPictures.contains(idx);
                      return GestureDetector(
                        onTap:
                            selectionMode
                                ? () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedPictures.remove(idx);
                                    } else {
                                      selectedPictures.add(idx);
                                    }
                                  });
                                }
                                : null,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(48.r),
                                child: Image.asset(
                                  'asset/img/home/sky.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (selectionMode && isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xff8287ff).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(48.r),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }, childCount: 1),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 60.h)),
      ],
    );
  }
}
