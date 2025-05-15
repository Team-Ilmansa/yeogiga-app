import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';

class TripWrapper extends StatefulWidget {
  const TripWrapper({super.key});

  @override
  State<TripWrapper> createState() => _TripWrapperState();
}

class _TripWrapperState extends State<TripWrapper> {
  // @override
  // void initState() {
  //   super.initState();
  //   SlidingUpPanelController();
  // }

  @override
  Widget build(BuildContext context) {
    SlidingUpPanelController panelController = SlidingUpPanelController();
    ScrollController scrollController = ScrollController();

    return Stack(
      children: <Widget>[
        Scaffold(body: Center(child: Text('아 되나?'))),
        SlidingUpPanelWidget(
          controlHeight: 50,
          panelController: panelController,
          onTap: () {
            ///Customize the processing logic
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
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.menu, size: 30),
                      Padding(padding: EdgeInsets.only(left: 8.0)),
                      Text('click or drag'),
                    ],
                  ),
                ),
                Divider(height: 0.5, color: Colors.grey[300]),
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: ListView.separated(
                      controller: scrollController,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(title: Text('list item $index'));
                      },
                      separatorBuilder: (context, index) {
                        return Divider(height: 0.5);
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
      ],
    );
  }
}
