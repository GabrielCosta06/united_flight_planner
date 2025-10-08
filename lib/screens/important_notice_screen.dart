// important_notice_screen.dart
import 'package:flutter/material.dart';
import 'select_travel_details_screen.dart';
import '../models/flight.dart';

class ImportantNoticeScreen extends StatelessWidget {
  final String currentEmployeeId;
  final Flight? flight;
  final Map<String, dynamic> checkInData;

  const ImportantNoticeScreen({
    super.key,
    required this.currentEmployeeId,
    this.flight,
    required this.checkInData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Important notice'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dress attire for pass riders\n\n"
                "All pass riders are to ensure that they are dressed appropriately. A pass rider's overall appearance should be well-groomed, neat, clean and in good taste. Attire should be respectful of revenue travelers, employees and fellow pass riders.\n\n"
                "The following attire is unacceptable in any cabin:\n"
                "• Attire that reveals a midriff or any type of undergarments\n"
                "• Attire that is designated as sleepwear, underwear or swim attire\n"
                "• Mini-skirts and shorts that are more than three inches above the knee when in a standing position\n"
                "• Form-fitting spandex tops, pants or dresses\n"
                "• Attire that has offensive and/or derogatory terms or graphics\n"
                "• Attire that is excessively dirty or has holes or tears\n"
                "• Attire that is provocative, inappropriately revealing or see-through\n"
                "• Bare feet or rubber, beach-type flip-flops\n\n"
                "All pass riders are required to adhere to the policy or they will be denied boarding. Once a pass rider is boarded on the aircraft, it is inappropriate to change into unacceptable attire.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Center(
                child: // In important_notice_screen.dart
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectTravelDetailsScreen(
                          currentEmployeeId: currentEmployeeId,
                          flight: flight,
                        ),
                      ),
                    );
                  },
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
