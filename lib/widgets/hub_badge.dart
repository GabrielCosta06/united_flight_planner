import 'package:flutter/material.dart';

const unitedBlue = Color.fromARGB(255, 0, 77, 155);

/// A small badge widget to mark hub airports.
class HubBadge extends StatelessWidget {
  const HubBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: unitedBlue,
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
