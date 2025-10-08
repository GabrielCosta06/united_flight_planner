import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_theme.dart';
import '../data/flight_data.dart';
import '../widgets/background.dart';
import 'flight_list_screen.dart';

class FlightInformationScreen extends StatefulWidget {
  final String origin;
  final String flightType; // e.g., domestic or international
  final String destination;
  final String currentEmployeeId;

  const FlightInformationScreen({
    super.key,
    required this.origin,
    required this.flightType,
    required this.destination,
    required this.currentEmployeeId,
  });

  @override
  State<FlightInformationScreen> createState() =>
      _FlightInformationScreenState();
}

class _FlightInformationScreenState extends State<FlightInformationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? _departureDate;
  String _selectedStops = 'Nonstop';
  String _selectedTripType = 'One-way';
  // Even though we have a dropdown for travel option,
  // we will NOT pass its value to FlightListScreen.
  late String _selectedTravelOption;
  final TextEditingController _travelAdvisoriesController =
      TextEditingController();
  final List<Map<String, dynamic>> _employeeNotes = [];
  final TextEditingController _employeeNoteController = TextEditingController();
  late String _selectedNoteAirport;

  final List<String> _stopsOptions = [
    'Nonstop',
    '1 Stop',
    '2 Stops',
    '3+ Stops'
  ];
  final List<String> _tripTypes = ['One-way', 'Roundtrip', 'Custom'];
  final List<String> _flightTypeOptions = [
    'Regular or award travel',
    'Company business travel (NRPS) (Authorization Required)',
    'United personal travel (NRSA)',
    'United emergency travel (NRPS - authorization required)',
    'United training travel (NRPS - authorization required)',
    'myUAdiscount travel',
  ];

  late AnimationController _planeController;

  @override
  void initState() {
    super.initState();
    _selectedNoteAirport = widget.origin;
    // Initialize dropdown selection; however, this value won't be passed on.
    _selectedTravelOption = _flightTypeOptions.contains(widget.flightType)
        ? widget.flightType
        : _flightTypeOptions.first;
    _loadEmployeeNotes();
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _travelAdvisoriesController.dispose();
    _employeeNoteController.dispose();
    _planeController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('employeeNotes');
    List<Map<String, dynamic>> globalNotes = [];
    if (notesJson != null) {
      globalNotes = List<Map<String, dynamic>>.from(json.decode(notesJson));
    }
    final now = DateTime.now();
    globalNotes = globalNotes.where((note) {
      DateTime noteDate = DateTime.parse(note['date']);
      return now.difference(noteDate).inDays < 7;
    }).toList();
    await prefs.setString('employeeNotes', json.encode(globalNotes));
    setState(() {
      _employeeNotes
        ..clear()
        ..addAll(globalNotes.where((note) =>
            note['airport'] == widget.origin ||
            note['airport'] == widget.destination));
    });
  }

  Future<void> _saveGlobalEmployeeNote(Map<String, dynamic> note) async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('employeeNotes');
    List<Map<String, dynamic>> globalNotes = [];
    if (notesJson != null) {
      globalNotes = List<Map<String, dynamic>>.from(json.decode(notesJson));
    }
    globalNotes.add(note);
    final now = DateTime.now();
    globalNotes.retainWhere((n) {
      DateTime noteDate = DateTime.parse(n['date']);
      return now.difference(noteDate).inDays < 7;
    });
    await prefs.setString('employeeNotes', json.encode(globalNotes));
    setState(() {
      _employeeNotes
        ..clear()
        ..addAll(globalNotes.where((n) =>
            n['airport'] == widget.origin ||
            n['airport'] == widget.destination));
    });
  }

  Future<void> _selectDepartureDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate != null && pickedDate != _departureDate) {
      setState(() => _departureDate = pickedDate);
    }
  }

  void _continueToFlightList() {
    // Use the original flight type from widget.flightType.
    debugPrint('Navigating with flight type: ${widget.flightType}');
    if (_formKey.currentState!.validate() && _departureDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightListScreen(
            origin: widget.origin,
            flightType: widget.flightType,
            destination: widget.destination,
            departureDate: _departureDate!,
            stops: _selectedStops,
            tripType: _selectedTripType,
            travelAdvisories: _travelAdvisoriesController.text,
            employeeNotes: _employeeNotes,
            currentEmployeeId: widget.currentEmployeeId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a departure date.',
            style: GoogleFonts.inter(),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Reusable vertical space widget.
  Widget _verticalSpace([double height = 16.0]) => SizedBox(height: height);

  TextStyle get _titleStyle => GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      );

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: GoogleFonts.inter(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey[600]) : null,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Departure Date', style: _titleStyle),
        _verticalSpace(8),
        InkWell(
          onTap: _selectDepartureDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blueGrey[800]),
                const SizedBox(width: 16),
                Text(
                  _departureDate == null
                      ? 'Select departure date'
                      : DateFormat('MMM dd, yyyy').format(_departureDate!),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: _departureDate == null
                        ? Colors.blueGrey[300]
                        : Colors.blueGrey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        _verticalSpace(8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: currentValue,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon, size: 20, color: Colors.blueGrey[600]),
                  if (icon != null) const SizedBox(width: 12),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      option,
                      style: GoogleFonts.inter(color: Colors.blueGrey[800]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey[800]),
          style: GoogleFonts.inter(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTextInputField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        _verticalSpace(8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint: hintText, icon: icon),
          maxLines: maxLines,
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }

  Widget _buildEmployeeNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Notes',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800])),
            _verticalSpace(16),
            DropdownButtonFormField<String>(
              initialValue: _selectedNoteAirport,
              items: [widget.origin, widget.destination]
                  .map((airport) => DropdownMenuItem(
                        value: airport,
                        child: Text(
                          airportCodes[airport] ?? airport,
                          style: GoogleFonts.inter(color: Colors.blueGrey[800]),
                        ),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedNoteAirport = value!),
              decoration: _inputDecoration(
                  hint: 'Select Airport', icon: Icons.location_on),
            ),
            _verticalSpace(16),
            TextFormField(
              controller: _employeeNoteController,
              decoration: _inputDecoration(
                  hint: 'Enter note about the airport...', icon: Icons.note),
              maxLines: 3,
              style: GoogleFonts.inter(),
            ),
            _verticalSpace(16),
            ElevatedButton(
              onPressed: () async {
                if (_employeeNoteController.text.trim().isNotEmpty) {
                  final newNote = {
                    'date': DateTime.now().toIso8601String(),
                    'employee': 'De Lima Santos Costa, Rafael',
                    'note': _employeeNoteController.text.trim(),
                    'airport': _selectedNoteAirport,
                  };
                  await _saveGlobalEmployeeNote(newNote);
                  _employeeNoteController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Add Note',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            _verticalSpace(16),
            if (_employeeNotes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Previous Notes:',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800])),
                  _verticalSpace(8),
                  ..._employeeNotes.reversed.map((note) {
                    DateTime noteDate = DateTime.parse(note['date']);
                    return ListTile(
                      leading: const Icon(Icons.note, color: AppColors.primary),
                      title: Text(note['note'], style: GoogleFonts.inter()),
                      subtitle: Text(
                        'By ${note['employee']} - ${DateFormat('MMM dd, yyyy, hh:mm a').format(noteDate)} (${airportCodes[note['airport']] ?? note['airport']})',
                        style: GoogleFonts.inter(),
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _FlightInfoAppBar(
        origin: widget.origin,
        destination: widget.destination,
        planeAnimation: _planeController,
      ),
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Flight Type Dropdown Section remains for display but its value is not passed.
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildDropdownField(
                        title: 'Flight Type',
                        currentValue: _selectedTravelOption,
                        options: _flightTypeOptions,
                        onChanged: (value) => setState(
                          () => _selectedTravelOption =
                              value ?? _selectedTravelOption,
                        ),
                        icon: Icons.flight,
                      ),
                    ),
                  ),
                  _verticalSpace(16),
                  // Flight Details Section.
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Flight Details',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800])),
                          _verticalSpace(16),
                          _buildDateField(),
                          _verticalSpace(20),
                          _buildDropdownField(
                            title: 'Number of Stops',
                            currentValue: _selectedStops,
                            options: _stopsOptions,
                            onChanged: (value) => setState(
                                () => _selectedStops = value ?? 'Nonstop'),
                            icon: Icons.airplanemode_active,
                          ),
                          _verticalSpace(20),
                          _buildDropdownField(
                            title: 'Trip Type',
                            currentValue: _selectedTripType,
                            options: _tripTypes,
                            onChanged: (value) => setState(
                                () => _selectedTripType = value ?? 'One-way'),
                            icon: Icons.flight_takeoff,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _verticalSpace(16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Additional Information',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800])),
                          _verticalSpace(16),
                          _buildTextInputField(
                            title: 'Travel Advisories',
                            hintText:
                                'E.g., visa requirements, health advisories',
                            controller: _travelAdvisoriesController,
                            icon: Icons.warning_amber_rounded,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _verticalSpace(16),
                  _buildEmployeeNotesSection(),
                  _verticalSpace(24),
                  ElevatedButton.icon(
                    onPressed: _continueToFlightList,
                    icon: const Icon(Icons.flight, color: Colors.white),
                    label: Text(
                      'Continue to Flights',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlightInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String origin;
  final String destination;
  final Animation<double> planeAnimation;
  const _FlightInfoAppBar({
    required this.origin,
    required this.destination,
    required this.planeAnimation,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/globe.png',
            height: 120,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flight Information',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      airportCodes[origin] ?? origin,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: planeAnimation,
                      builder: (context, child) {
                        double offsetX =
                            2 * math.sin(planeAnimation.value * 4 * math.pi);
                        return Transform.translate(
                          offset: Offset(offsetX, 0),
                          child: child,
                        );
                      },
                      child: Transform.rotate(
                        angle: math.pi / 2,
                        child: const Icon(
                          Icons.airplanemode_active,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      airportCodes[destination] ?? destination,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
