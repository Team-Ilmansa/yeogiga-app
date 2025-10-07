import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/user/provider/auth_provider.dart';
import 'package:yeogiga/common/route_observer.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // watch - 값이 변경될때마다 다시 빌드
  // read - 한번만 읽고 값이 변경돼도 다시 빌드하지 않음
  final provider = ref.read(authProvider);

  return GoRouter(
    routes: _wrapRoutesWithAnimation(provider.routes),
    initialLocation: '/splash',
    refreshListenable: provider,
    redirect: provider.redirectLogic,
    observers: [
      myPageRouteObserver,
      homeRouteObserver,
      tripDetailRouteObserver,
    ],
  );
});

// 모든 라우트에 애니메이션 적용
List<RouteBase> _wrapRoutesWithAnimation(List<RouteBase> routes) {
  return routes.map((route) {
    if (route is GoRoute) {
      // 이미 pageBuilder가 있으면 그대로 유지
      if (route.pageBuilder != null) {
        return route;
      }

      // builder만 있는 경우 pageBuilder로 변환하여 애니메이션 추가
      if (route.builder != null) {
        return GoRoute(
          path: route.path,
          name: route.name,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: route.builder!(context, state),
                transitionDuration: const Duration(milliseconds: 150),
                reverseTransitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.fastOutSlowIn;

                  var slideTween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeIn),
                  );

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: animation.drive(slideTween),
                      child: child,
                    ),
                  );
                },
              ),
          redirect: route.redirect,
          routes: route.routes,
        );
      }
    }
    return route;
  }).toList();
}
