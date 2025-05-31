import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/main_trip/view/home_screen.dart';
import 'package:yeogiga/trip/component/past_trip_card.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/repository/register_repository.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tripListProvider.notifier).fetchAndSetTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SectionTitle("내 여행 모두 보기"),
        PastTripCardList(trips: ref.watch(tripListProvider)),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(userMeProvider.notifier).logout();
              },
              child: Text('로그아웃'),
            ),
            SizedBox(width: 40.w),
            ElevatedButton(
              onPressed: () {
                ref.read(registerRepositoryProvider).deleteUser();
              },
              child: Text('회원탈퇴'),
            ),
          ],
        ),
      ],
    );
  }
}
