// select_passport_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight.dart';

class SelectPassportScreen extends StatefulWidget {
  final String currentEmployeeId;
  final Flight? flight;
  final Map<String, dynamic> checkInData;

  const SelectPassportScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
    required this.checkInData,
  });

  @override
  State<SelectPassportScreen> createState() => _SelectPassportScreenState();
}

class _SelectPassportScreenState extends State<SelectPassportScreen> {
  bool savePassportDetails = false;

  // Sample passport details data (this can be replaced with your own model)
  final Map<String, String> passportDetails = {
    "title": "United States Passport",
    "nationality": "United States",
    "gender": "Male",
    "dateOfBirth": "01/01/1980",
    "name": "Rafael Costa",
    "docNumber": "A12345678", // will be masked (A******8)
    "expiration": "12/31/2030", // will be masked (e.g. **/31/2030)
  };

  // Helper method to mask the document number
  String maskDocNumber(String docNumber) {
    if (docNumber.length < 3) return docNumber;
    return docNumber[0] +
        List.filled(docNumber.length - 2, '*').join() +
        docNumber[docNumber.length - 1];
  }

  // Helper method to mask the expiration date (masking first two characters)
  String maskExpiration(String expiration) {
    if (expiration.length < 2) return expiration;
    return "**${expiration.substring(2)}";
  }

  @override
  Widget build(BuildContext context) {
    // Use the user's name from checkInData if available; otherwise default to currentEmployeeId.
    final userName = widget.checkInData['userName'] ?? widget.currentEmployeeId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select passport"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$userName, please confirm which passport you are traveling with today.",
                style: GoogleFonts.inter(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passportDetails["title"] ?? "",
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Nationality: ${passportDetails["nationality"]}",
                        style: GoogleFonts.inter(),
                      ),
                      Text(
                        "Gender: ${passportDetails["gender"]}",
                        style: GoogleFonts.inter(),
                      ),
                      Text(
                        "Date of Birth: ${passportDetails["dateOfBirth"]}",
                        style: GoogleFonts.inter(),
                      ),
                      Text(
                        "Name: ${passportDetails["name"]}",
                        style: GoogleFonts.inter(),
                      ),
                      Text(
                        "Doc Number: ${maskDocNumber(passportDetails["docNumber"] ?? "")}",
                        style: GoogleFonts.inter(),
                      ),
                      Text(
                        "Expiration: ${maskExpiration(passportDetails["expiration"] ?? "")}",
                        style: GoogleFonts.inter(),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          // Navigate to ReplacePassportScreen while passing the necessary arguments
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplacePassportScreen(
                                currentEmployeeId: widget.currentEmployeeId,
                                flight: widget.flight,
                                checkInData: widget.checkInData,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Replace this passport",
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.blue),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "By selecting \"Replace this passport,\" you acknowledge that\nUnited may share your information with a third party to\nprovide this service and you agree to the use, transfer and\nprocessing of your information as described in United's\nPrivacy Policy.",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              Text(
                "Would you like to save your passport details for future travel?\nIf you do not save your passport, any previously stored passport details\nwill also be removed.",
                style: GoogleFonts.inter(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Save my passport details"),
                value: savePassportDetails,
                onChanged: (bool value) {
                  setState(() {
                    savePassportDetails = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to ConfirmationScreen while passing the required arguments
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmationScreen(
                              currentEmployeeId: widget.currentEmployeeId,
                              flight: widget.flight,
                              checkInData: widget.checkInData,
                            ),
                          ),
                        );
                      },
                      child: const Text("Confirm selected passport"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to ConfirmationScreen (or the next screen) while passing the arguments
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmationScreen(
                              currentEmployeeId: widget.currentEmployeeId,
                              flight: widget.flight,
                              checkInData: widget.checkInData,
                            ),
                          ),
                        );
                      },
                      child: const Text("Continue without passport"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dummy screen for replacing passport details.
class ReplacePassportScreen extends StatelessWidget {
  final String currentEmployeeId;
  final Flight? flight;
  final Map<String, dynamic> checkInData;

  const ReplacePassportScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
    required this.checkInData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Replace Passport"),
      ),
      body: Center(
        child: Text(
          "Replace Passport Screen",
          style: GoogleFonts.inter(fontSize: 16),
        ),
      ),
    );
  }
}

/// Dummy confirmation screen after passport selection.
class ConfirmationScreen extends StatelessWidget {
  final String currentEmployeeId;
  final Flight? flight;
  final Map<String, dynamic> checkInData;

  const ConfirmationScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
    required this.checkInData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmation"),
      ),
      body: Center(
        child: Text(
          "Passport confirmed (or continued without passport)",
          style: GoogleFonts.inter(fontSize: 16),
        ),
      ),
    );
  }
}
