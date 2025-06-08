import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/main_trip/view/home_screen.dart';
import 'package:yeogiga/common/component/past_trip_card.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/repository/register_repository.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/w2m/model/user_w2m_model.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';
import 'package:yeogiga/common/route_observer.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> with RouteAware {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tripListProvider.notifier).fetchAndSetTrips();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver 등록
    myPageRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // RouteObserver 해제
    myPageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 마이페이지가 다시 보일 때마다 새로고침
    ref.read(tripListProvider.notifier).fetchAndSetTrips();
    super.didPopNext();
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
                ref.invalidate(tripProvider); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                ref.invalidate(
                  confirmScheduleProvider,
                ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                ref.invalidate(
                  pendingScheduleProvider,
                ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                ref.invalidate(
                  completedScheduleProvider,
                ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
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
            SizedBox(height: 70.h),
            // TODO: 여행 참가하기 버튼
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  backgroundColor: Color(0xff8287ff),
                ),
                onPressed: () async {
                  final tripIdController = TextEditingController();
                  int? tripId;
                  if (!context.mounted) return;
                  final inputResult = await showDialog<int>(
                    context: context,
                    builder:
                        (context) => Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                          insetPadding: EdgeInsets.all(48.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40.w,
                              vertical: 40.h,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
                                  child: Text(
                                    '여행 참가',
                                    style: TextStyle(
                                      fontSize: 54.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff313131),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 48.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
                                  child: CustomTextFormField(
                                    controller: tripIdController,
                                    hintText: '참가할 여행 ID를 입력하세요',
                                    onChanged: (value) {},
                                  ),
                                ),
                                SizedBox(height: 40.h),
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xff8287ff,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            48.r,
                                          ),
                                        ),
                                        elevation: 0,
                                        minimumSize: Size(0, 150.h),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        final id = int.tryParse(
                                          tripIdController.text.trim(),
                                        );
                                        if (id != null) {
                                          Navigator.of(context).pop(id);
                                        }
                                      },
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                          fontSize: 48.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                  tripId = inputResult;
                  if (tripId == null) return;

                  // 참가 확인 다이얼로그
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 38.h,
                              horizontal: 40.w,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF8287FF),
                                  size: 120.w,
                                ),
                                SizedBox(height: 48.h),
                                Text(
                                  '해당 여행에 참가하시겠습니까?',
                                  style: TextStyle(
                                    fontSize: 56.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff313131),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 50.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              42.r,
                                            ),
                                          ),
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                            fontSize: 48.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 32.w),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF8287FF,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              42.r,
                                            ),
                                          ),
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                            fontSize: 48.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                  if (confirm != true) return;

                  // joinTrip 실행 및 결과 다이얼로그
                  bool success = false;
                  String? errorMsg;
                  try {
                    success = await ref
                        .read(tripProvider.notifier)
                        .joinTrip(tripId);
                  } catch (e) {
                    success = false;
                    errorMsg =
                        e is Exception
                            ? e.toString().replaceFirst('Exception:', '').trim()
                            : e.toString();
                  }
                  if (context.mounted) {
                    await showDialog(
                      context: context,
                      builder:
                          (context) => Dialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48.r),
                            ),
                            insetPadding: EdgeInsets.all(48.w),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 40.h,
                                horizontal: 40.w,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    success
                                        ? Icons.check_circle_outline
                                        : Icons.error_outline,
                                    color:
                                        success
                                            ? const Color(0xFF8287FF)
                                            : Colors.red,
                                    size: 120.w,
                                  ),
                                  SizedBox(height: 48.h),
                                  Text(
                                    success
                                        ? '여행 참가에 성공했습니다!'
                                        : '여행 참가에 실패했습니다${errorMsg != null ? "\n$errorMsg" : ""}',
                                    style: TextStyle(
                                      fontSize: 56.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff313131),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 50.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            success
                                                ? const Color(0xFF8287FF)
                                                : Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            42.r,
                                          ),
                                        ),
                                        elevation: 0,
                                        minimumSize: Size.fromHeight(156.h),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                          fontSize: 48.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                  }
                },

                child: Text(
                  '여행 참가하기',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
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
