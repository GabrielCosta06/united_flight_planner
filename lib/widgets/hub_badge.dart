import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// A small badge widget to mark hub airports.
class HubBadge extends StatelessWidget {
  const HubBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.star,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}
