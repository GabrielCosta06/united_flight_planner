import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';


class AccommodationsTransportations extends StatelessWidget {
  const AccommodationsTransportations({super.key});

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _LinkCard(label: 'Hotels', icon: Icons.hotel, onTap: () {}),
        _LinkCard(label: 'Airbnb', icon: Icons.house, onTap: () {}),
        _LinkCard(
            label: 'Car Rental', icon: Icons.directions_car, onTap: () {}),
        _LinkCard(
          label: 'ID90 Travel',
          icon: Icons.travel_explore,
          onTap: () => _launchUrl('https://www.id90travel.com/'),
        ),
        _LinkCard(
          label: 'myIDTravel',
          icon: Icons.airplanemode_active,
          onTap: () => _launchUrl('https://myidtravel.com/'),
        ),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _LinkCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
