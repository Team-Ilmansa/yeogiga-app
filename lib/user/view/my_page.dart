import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/main_trip/view/home_screen.dart';
import 'package:yeogiga/common/component/past_trip_card.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/repository/register_repository.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/w2m/model/user_w2m_model.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';

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
        Column(
          children: [
            SectionTitle("내 여행 모두 보기"),
            PastTripCardList(
              trips: ref.watch(tripListProvider),
              onTap: (tripId) async {
                await ref.read(tripProvider.notifier).getTrip(tripId: tripId);
                final tripState = ref.read(tripProvider);
                final userW2mState = ref.read(userW2mProvider);
                if (context.mounted) {
                  if (tripState is SettingTripModel &&
                      userW2mState is NoUserW2mModel) {
                    GoRouter.of(context).push('/dateRangePicker');
                  } else {
                    GoRouter.of(context).push('/tripDetailScreen');
                  }
                }
              },
            ),
          ],
        ),

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
