import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

class SettingSliderPanel extends StatelessWidget {
  final SlidingUpPanelController panelController;
  final ScrollController scrollController;
  const SettingSliderPanel({
    Key? key,
    required this.panelController,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: SlidingUpPanelWidget(
        controlHeight: 50.h,
        panelController: panelController,
        onTap: () {
          if (SlidingUpPanelStatus.expanded == panelController.status) {
            panelController.collapse();
          } else {
            panelController.expand();
          }
        },
        enableOnTap: true,
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shadows: [
              BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 2.0,
                color: const Color(0x11000000),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0.r),
                topRight: Radius.circular(10.0.r),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                height: 50.0.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.menu, size: 30.sp),
                    Padding(padding: EdgeInsets.only(left: 8.0.w)),
                    Text('click or drag', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
              ),
              Divider(height: 0.5.h, color: Colors.grey[300]),
              Flexible(
                child: Container(
                  color: Colors.white,
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          'list item $index',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(height: 0.5.h);
                    },
                    shrinkWrap: true,
                    itemCount: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
