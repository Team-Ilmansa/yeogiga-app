import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/trip/model/trip_member_location.dart';
import 'package:yeogiga/trip/trip_map/ing/member_marker_widget.dart';

class MarkerPreviewScreen extends StatelessWidget {
  static const routeName = 'markerPreview';

  const MarkerPreviewScreen({super.key});

  TripMemberLocation get _sampleMemberWithImage => TripMemberLocation(
    latitude: 37.5665,
    longitude: 126.9780,
    userId: 0,
    nickname: '김여행',
    imageUrl: 'https://picsum.photos/200',
  );

  TripMemberLocation get _sampleMemberWithoutImage => TripMemberLocation(
    latitude: 37.5665,
    longitude: 126.9780,
    userId: 1,
    nickname: '박동행',
    imageUrl: null,
  );

  @override
  Widget build(BuildContext context) {
    final style = MemberMarkerStyle();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marker Preview'),
        actions: [
          TextButton(
            onPressed: () => context.go('/splash'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('앱 시작', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreviewCard(
                title: '이미지 있는 멤버',
                child: MemberMarkerWidget(
                  member: _sampleMemberWithImage,
                  style: style,
                ),
              ),
              SizedBox(height: 32.h),
              _PreviewCard(
                title: '이미지 없는 멤버',
                child: MemberMarkerWidget(
                  member: _sampleMemberWithoutImage,
                  style: style,
                ),
              ),
              SizedBox(height: 48.h),
              Text(
                '앱으로 돌아가려면 상단 우측 버튼을 눌러주세요.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xff7d7d7d),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff313131),
            ),
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }
}
