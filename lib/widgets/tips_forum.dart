import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color unitedBlue = Color(0xFF005DAA);

/// A widget that shows a list of travel tip posts.
class TravelTipsForum extends StatelessWidget {
  const TravelTipsForum({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TipPost(
          employeeName: "Alice",
          tip: "Book your tickets in advance to save money!",
        ),
        _TipPost(
          employeeName: "Bob",
          tip: "Bring an empty water bottle to fill up after security.",
        ),
        _TipPost(
          employeeName: "Carol",
          tip: "Use translation apps for international destinations.",
        ),
      ],
    );
  }
}

/// A single travel tip post.
class _TipPost extends StatelessWidget {
  final String employeeName;
  final String tip;
  const _TipPost({
    super.key,
    required this.employeeName,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: unitedBlue,
          child: Text(
            employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          employeeName,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(tip, style: GoogleFonts.inter()),
      ),
    );
  }
}
