import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/common/provider/permission_provider.dart';

class PermissionRequestScreen extends ConsumerStatefulWidget {
  static const routeName = 'permissionRequest';

  final String? initialError;
  const PermissionRequestScreen({super.key, this.initialError});

  @override
  ConsumerState<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState
    extends ConsumerState<PermissionRequestScreen>
    with WidgetsBindingObserver {
  bool _isRequesting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.initialError;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      ref.invalidate(permissionStatusProvider);
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
      _errorMessage = null;
    });

    final service = ref.read(permissionServiceProvider);
    final granted = await service.requestAllPermissions();

    if (!mounted) return;

    setState(() {
      _isRequesting = false;
      if (!granted) {
        _errorMessage =
            '위치 권한을 "항상 허용"으로 설정해야 서비스를 이용할 수 있어요.\n필요 시 설정 > 앱 관리에서 권한을 변경해주세요.\n(알림 · 카메라 · 사진/동영상 권한도 허용하면 기능을 온전히 이용할 수 있어요.)';
      }
    });

    if (granted) {
      ref.invalidate(permissionStatusProvider);
    }
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
    if (!mounted) return;
    ref.invalidate(permissionStatusProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Text(
                '권한 안내',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff313131),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '여행 중 위치 공유 · 사진 업로드 · 알림을 위해\n다음 권한이 필요해요.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xff5f5f5f),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              _buildPermissionTile(
                title: '위치 권한 (항상 허용)',
                description: '여행 중 언제든지 팀원들과 위치를 공유하기 위해\n"항상 허용"으로 설정이 필요해요.',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 18.h),
              _buildPermissionTile(
                title: '알림 권한',
                description:
                    '여행 일정 변경, 위치 동기화 등 중요한 소식을\n제때 받아볼 수 있도록 알림을 허용해주세요.',
                icon: Icons.notifications_none,
              ),
              SizedBox(height: 18.h),
              _buildPermissionTile(
                title: '카메라 권한',
                description: '여행 중 사진을 촬영해 바로 공유할 수 있도록\n카메라 접근 권한이 필요해요.',
                icon: Icons.camera_alt_outlined,
              ),
              SizedBox(height: 18.h),
              _buildPermissionTile(
                title: '사진/동영상 접근 권한',
                description:
                    '갤러리에 있는 추억 사진을 업로드하고 저장하려면\n사진·동영상 접근 권한을 허용해야 해요.',
                icon: Icons.photo_library_outlined,
              ),
              SizedBox(height: 24.h),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8287ff),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child:
                      _isRequesting
                          ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                          : Text(
                            '권한 허용하기',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              TextButton(
                onPressed: _openAppSettings,
                child: Text(
                  '설정에서 직접 허용하기',
                  style: TextStyle(
                    color: const Color(0xff8287ff),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xfff5f6ff),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xffe5e7ff),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xff5a61f8)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff313131),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xff5f5f5f),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
