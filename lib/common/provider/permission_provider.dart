import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/service/permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final permissionStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(permissionServiceProvider);
  return service.hasAllPermissions();
});
