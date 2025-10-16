import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_theme.dart';

/// Base layout for baggage-related informational pages.
class _BaggageInfoLayout extends StatelessWidget {
  const _BaggageInfoLayout({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<_InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: AppColors.primary,
        elevation: 4,
        toolbarHeight: 50,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Image.asset(
                'assets/images/globe.png',
                height: 150,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(section.icon, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          section.title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...section.points.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '- $point',
                        style: GoogleFonts.inter(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: sections.length,
      ),
    );
  }
}

/// Screen describing baggage allowance specifics.
class BaggageDetailsScreen extends StatelessWidget {
  const BaggageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaggageInfoLayout(
      title: 'Baggage Details',
      sections: const [
        _InfoSection(
          title: 'Carry-on allowance',
          icon: Icons.work_outline,
          points: [
            'One full-size carry-on bag and one personal item included.',
            'Carry-on must fit in the overhead bin (9" x 14" x 22").',
            'Personal items should fit under the seat in front of you.',
          ],
        ),
        _InfoSection(
          title: 'Checked baggage',
          icon: Icons.luggage,
          points: [
            'Standard checked bag fee starts at \$35 for the first bag.',
            'Maximum weight 50 lbs (23 kg); oversize fees may apply.',
            'Premier members receive complimentary checked bags.',
          ],
        ),
        _InfoSection(
          title: 'Special items',
          icon: Icons.sports_esports,
          points: [
            'Sports equipment counts as a checked bag; oversized fees may apply.',
            'Fragile items should be packed securely and labeled.',
            'Contact United Contact Center for advance arrangements.',
          ],
        ),
      ],
    );
  }
}

/// Screen summarizing baggage rules and optional service fees.
class BaggageRulesScreen extends StatelessWidget {
  const BaggageRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaggageInfoLayout(
      title: 'Baggage Rules & Services',
      sections: const [
        _InfoSection(
          title: 'General rules',
          icon: Icons.rule,
          points: [
            'Check in bags at least 45 minutes before domestic departures.',
            'Label all checked bags with your name and contact information.',
            'Hazardous materials are prohibited per TSA regulations.',
          ],
        ),
        _InfoSection(
          title: 'Optional services',
          icon: Icons.attach_money,
          points: [
            'Upgrade to Economy Plus seating starting at \$20, subject to availability.',
            'Priority baggage handling is available for MileagePlus Premier members.',
            'Same-day standby and confirmed flight changes may incur fees.',
          ],
        ),
        _InfoSection(
          title: 'International considerations',
          icon: Icons.public,
          points: [
            'Country-specific restrictions can affect allowance and fees.',
            'Customs inspections may require unlocking your luggage.',
            'Allow extra time for rechecking bags on connecting itineraries.',
          ],
        ),
      ],
    );
  }
}

class _InfoSection {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.points,
  });

  final String title;
  final IconData icon;
  final List<String> points;
}
