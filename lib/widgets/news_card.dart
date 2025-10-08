import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const NewsCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => debugPrint("NewsCard tapped"),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Icon(Icons.article, size: 30, color: Colors.grey[600]),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(subtitle, style: GoogleFonts.inter()),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

/// A widget that encapsulates the list of news cards.
class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const NewsCard(
          title: 'Company Update',
          subtitle: 'New safety protocols have been announced.',
        ),
        const NewsCard(
          title: 'Airport Delays',
          subtitle: 'Several flights delayed due to inclement weather.',
        ),
        const NewsCard(
          title: 'New In-Flight Menu',
          subtitle: 'Introducing our new gourmet menu for premium passengers.',
        ),
        NewsCard(
          title: 'Airport News',
          subtitle: 'Real‑time updates for every airport.',
          onTap: () => _launchURL('https://unitedview.ual.com/'),
        ),
      ],
    );
  }
}
