import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pull-to-refresh wrapper tuned for scrollables that live inside
/// [NestedScrollView] bodies. It only reacts to direct descendant scroll
/// notifications and waits for a meaningful overscroll distance before
/// arming the refresh callback, preventing accidental refreshes when content
/// is merely tapped at the scroll edge.
class NestedRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final double offsetToArmed;

  const NestedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.offsetToArmed = 96.0,
  });

  @override
  Widget build(BuildContext context) {
    const indicatorExtent = 70.0;

    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      offsetToArmed: offsetToArmed,
      notificationPredicate: (notification) {
        if (notification.depth != 0) return false;
        final axisDirection = notification.metrics.axisDirection;
        return axisDirection == AxisDirection.down;
      },
      triggerMode: IndicatorTriggerMode.onEdge,
      builder: (context, child, controller) {
        final bool pullingFromTop =
            controller.side == IndicatorSide.top || !controller.hasEdge;

        final bool isActive = controller.isLoading || controller.isComplete;
        final bool shouldHoldSpace = isActive;
        final bool shouldDrawIndicator =
            pullingFromTop &&
            (controller.isDragging ||
                controller.isArmed ||
                controller.isSettling ||
                controller.isLoading ||
                controller.isComplete ||
                controller.isFinalizing);

        final double rawProgress = controller.value.clamp(
          0.0,
          CustomRefreshIndicator.armedFromValue,
        );
        final double effectiveProgress = shouldHoldSpace ? 1.0 : rawProgress;
        final double displacement =
            pullingFromTop ? indicatorExtent * effectiveProgress : 0.0;

        final double indicatorTop = displacement - indicatorExtent;
        final double indicatorOpacity =
            controller.isLoading ? 1.0 : rawProgress;

        final indicator = SizedBox(
          height: indicatorExtent,
          child: Align(
            alignment: Alignment.center,
            child: _LogoSpinner(
              progress: rawProgress,
              isLoading: controller.isLoading,
            ),
          ),
        );

        final double contentOpacity = (1 - rawProgress).clamp(0, 1.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, displacement),
              child: Opacity(opacity: contentOpacity, child: child),
            ),
            if (shouldDrawIndicator)
              Positioned(
                top: indicatorTop,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: indicatorOpacity.clamp(0.0, 1.0),
                    child: indicator,
                  ),
                ),
              ),
          ],
        );
      },
      child: child,
    );
  }
}

// 로고스피너
class _LogoSpinner extends StatelessWidget {
  final double progress;
  final bool isLoading;

  const _LogoSpinner({required this.progress, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final indicatorColor = const Color(0xff8287ff);
    final double ringSize = 44.w;

    return Opacity(
      opacity: isLoading ? 1.0 : clampedProgress,
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: ringSize,
              height: ringSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: AlwaysStoppedAnimation(indicatorColor),
                value: isLoading ? null : clampedProgress,
              ),
            ),
            Image.asset('asset/img/logo/logo.png', width: 24.w, height: 24.h),
          ],
        ),
      ),
    );
  }
}
