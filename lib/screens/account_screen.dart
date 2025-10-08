import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '/data/employee_data.dart'; // Adjust the import if needed

const Color unitedBlue = Color(0xFF005DAA);

class AccountScreen extends StatefulWidget {
  final String currentEmployeeId; // This is actually the username.
  const AccountScreen({super.key, required this.currentEmployeeId});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // For mobile: file path based image.
  File? _profileImage;
  // For web: store image bytes.
  Uint8List? _profileImageBytes;
  Employee? currentEmployee;

  // Quick Links Data Structure
  final Map<String, List<String>> quickLinksData = {
    'Employee Links:': [
      'Egencia (Company Business Hotel Search)',
      'Employee Travel Profile',
      'Employee Discounts',
      'Flying Together',
      'Help Hub',
      'Manage Travelers',
      'MileagePlus',
      'MyUADiscount',
      'Pass Travel Report',
      'Travel Homepage',
    ],
    'Travel Policies:': [
      'Pass Travel Attire',
      'Pass Travel Guidelines',
      'Travel Policies Overview',
      'Passrider User Guide',
      'Jumpseat User Guide',
    ],
    'Helpful Travel Links:': [
      'Embargo List',
      'United Route Map',
      'Pass Calculator',
      'Request Refund',
      'Verification Of Eligibility Letter',
    ],
    'Other Airline (OA) Travel:': [
      'ID90Travel',
      'MyIDTravelPurchase',
      'Other Airline Travel Homepage',
      'ZED Fare Chart',
    ],
    'Frequently Asked Questions (FAQs):': [
      'Eres Site FAQs',
      'Manage Travel FAQs',
      'Uax Reciprocal Jumpseat FAQs',
      'Travel FAQs',
      'Psl FAQs',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Load employee data from JSON.
    loadEmployeeData();
    // Retrieve the employee matching the currentEmployeeId by comparing to username.
    currentEmployee = employees.firstWhere(
      (e) => e.username == widget.currentEmployeeId,
      orElse: () => Employee(
        employeeId: widget.currentEmployeeId,
        name: 'Unknown',
        username: '',
        password: '',
        email: '',
        abbreviatedName: '',
        abbreviatedName2: '',
        profileImagePath: '',
        passType: '',
      ),
    );
    // Load the profile image if one was previously set (mobile only).
    if (!kIsWeb && currentEmployee!.profileImagePath.isNotEmpty) {
      _profileImage = File(currentEmployee!.profileImagePath);
    }
  }

  // Opens the image picker and updates the employee record with the new image path or bytes.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        // For web: read the image bytes.
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
      } else {
        // For mobile: update the employee data with the new profile image path.
        updateEmployeeProfileImage(widget.currentEmployeeId, pickedFile.path);
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    }
  }

  List<Widget> buildQuickLinks(BuildContext context) {
    List<Widget> widgets = [];
    quickLinksData.forEach((header, links) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: unitedBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              header,
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: unitedBlue,
              ),
            ),
          ),
        ),
      );
      widgets.addAll(
        links.map((link) => ListTile(
              title: Text(
                link,
                style: GoogleFonts.inter(),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$link clicked')),
                );
              },
            )),
      );
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // Use currentEmployee data if available, else fallback to default values.
    final employeeName = currentEmployee?.name ?? 'Unknown';
    final employeeEmail = currentEmployee?.email ?? '';
    final employeeUsername = currentEmployee?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: unitedBlue,
        elevation: 4,
        toolbarHeight: 50,
        centerTitle: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/globe.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                'Account Information',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
            gradient: const LinearGradient(
              colors: [unitedBlue, Color.fromARGB(255, 23, 0, 65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Account Information Card.
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Profile picture with edit option.
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: kIsWeb
                              ? (_profileImageBytes != null
                                  ? MemoryImage(_profileImageBytes!)
                                      as ImageProvider<Object>
                                  : null)
                              : (_profileImage != null
                                  ? FileImage(_profileImage!)
                                      as ImageProvider<Object>
                                  : null),
                          child: (kIsWeb
                                  ? _profileImageBytes == null
                                  : _profileImage == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: unitedBlue,
                              child: const Icon(
                                Icons.edit,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // User details.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee ID: ${currentEmployee?.employeeId ?? 'Unknown'}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            employeeName,
                            style: GoogleFonts.inter(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Username: $employeeUsername',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            employeeEmail,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Programs & Policies Menu Card.
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.menu_book, color: unitedBlue),
                title: Text(
                  'Programs & Policies',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  ListTile(
                    title: Text('Types of travel', style: GoogleFonts.inter()),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Types of travel clicked')),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Travel policies', style: GoogleFonts.inter()),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Travel policies clicked')),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Trusted traveler programs',
                        style: GoogleFonts.inter()),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Trusted traveler programs clicked')),
                      );
                    },
                  ),
                  ListTile(
                    title:
                        Text('Retiree pass travel', style: GoogleFonts.inter()),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Retiree pass travel clicked')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Quick Links Menu Card.
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.link, color: unitedBlue),
                title: Text(
                  'Quick Links',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: buildQuickLinks(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
