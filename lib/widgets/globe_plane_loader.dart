import 'package:flutter/material.dart';

/// Displays the animated United globe + plane spinner used across the app.
class GlobePlaneLoader extends StatelessWidget {
  const GlobePlaneLoader({
    super.key,
    this.size = 140,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/loading.gif',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Full-screen overlay that shows the globe animation centered on-screen.
class GlobePlaneLoaderOverlay extends StatelessWidget {
  const GlobePlaneLoaderOverlay({
    super.key,
    this.loaderSize = 160,
    this.backdropOpacity = 0,
  });

  final double loaderSize;
  final double backdropOpacity;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: backdropOpacity),
      child: Center(
        child: GlobePlaneLoader(size: loaderSize),
      ),
    );
  }
}
