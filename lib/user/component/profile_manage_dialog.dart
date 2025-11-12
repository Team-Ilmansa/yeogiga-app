import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/common/component/simple_loading_dialog.dart';
import 'package:yeogiga/common/utils/profile_placeholder_util.dart';
import 'package:yeogiga/common/utils/snackbar_helper.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class ProfileManageDialog extends ConsumerStatefulWidget {
  const ProfileManageDialog({super.key});

  @override
  ConsumerState<ProfileManageDialog> createState() =>
      _ProfileManageDialogState();
}

class _ProfileManageDialogState extends ConsumerState<ProfileManageDialog> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNicknameUpdating = false;
  bool _isImageUploading = false;
  File? _previewImage;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userMeProvider);
    final user = _extractUser(userState);
    final nicknameHint = user?.nickname ?? '닉네임을 입력해주세요';

    return Dialog(
      backgroundColor: Color(0xfffafafa),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '프로필 관리',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff313131),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Center(
                child: GestureDetector(
                  onTap: _isImageUploading ? null : _pickProfileImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildAvatar(user),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: const Color(0xff8287ff),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  '프로필 사진을 누르면 변경할 수 있어요',
                  style: TextStyle(
                    color: const Color(0xFF7D7D7D),
                    fontSize: 14.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                    letterSpacing: -0.42,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                '닉네임',
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 14.sp,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                  letterSpacing: -0.48,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                controller: _nicknameController,
                hintText: nicknameHint,
                enabled: !_isNicknameUpdating,
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNicknameUpdating ? null : _submitNickname,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8287ff),
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child:
                      _isNicknameUpdating
                          ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            '닉네임 변경',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.40,
                              letterSpacing: -0.48,
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

  Widget _buildAvatar(UserModel? user) {
    final imageProvider = _resolveImageProvider(user);

    final size = 110.w;

    if (imageProvider == null) {
      final nickname = user?.nickname ?? '사용자';
      return ClipOval(
        child: buildProfileAvatarPlaceholder(nickname: nickname, size: size),
      );
    }

    return ClipOval(
      child: Image(
        image: imageProvider,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  ImageProvider? _resolveImageProvider(UserModel? user) {
    if (_previewImage != null) {
      return FileImage(_previewImage!);
    }

    final imageUrl = user?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    }

    return null;
  }

  Future<void> _pickProfileImage() async {
    final granted = await _ensureMediaPermission();
    if (!granted) {
      showAppSnackBar(
        context,
        '사진 접근 권한을 허용해주세요.',
        isError: true,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) {
      showAppSnackBar(
        context,
        '이미지를 불러오지 못했어요.',
        isError: true,
      );
      return;
    }

    final file = File(path);
    setState(() {
      _previewImage = file;
      _isImageUploading = true;
    });

    bool dialogShown = false;
    if (mounted) {
      dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SimpleLoadingDialog(message: '프로필 사진을 반영하는 중이에요'),
      );
    }

    final error = await ref
        .read(userMeProvider.notifier)
        .updateProfileImage(file);

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, '프로필 사진이 변경되었어요.');
      setState(() {
        _previewImage = null;
      });
    }

    if (dialogShown && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    setState(() {
      _isImageUploading = false;
    });
  }

  Future<void> _submitNickname() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      showAppSnackBar(context, '닉네임을 입력해주세요.', isError: true);
      return;
    }

    setState(() {
      _isNicknameUpdating = true;
    });

    final error = await ref
        .read(userMeProvider.notifier)
        .updateNickname(nickname);

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, '닉네임이 변경되었어요.');
      _nicknameController.clear();
    }

    setState(() {
      _isNicknameUpdating = false;
    });
  }

  UserModel? _extractUser(UserModelBase? state) {
    if (state is UserResponseModel) {
      return state.data;
    } else if (state is UserModel) {
      return state;
    }
    return null;
  }

  Future<bool> _ensureMediaPermission() async {
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;

    if (photosStatus.isGranted || storageStatus.isGranted) {
      return true;
    }

    final photosResult = await Permission.photos.request();
    if (photosResult.isGranted) {
      return true;
    }

    final storageResult = await Permission.storage.request();
    return storageResult.isGranted;
  }

}
