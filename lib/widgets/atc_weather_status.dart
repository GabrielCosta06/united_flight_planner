import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

enum SeverityLevel { normal, low, medium, high, extreme }

class AirportStatus {
  final String airportName;
  final String terminal;
  final SeverityLevel severity;
  const AirportStatus({
    required this.airportName,
    required this.terminal,
    required this.severity,
  });
}

Color getSeverityColor(SeverityLevel level) {
  switch (level) {
    case SeverityLevel.normal:
      return Colors.green;
    case SeverityLevel.low:
      return Colors.yellow.shade700;
    case SeverityLevel.medium:
      return Colors.orange;
    case SeverityLevel.high:
      return Colors.red;
    case SeverityLevel.extreme:
      return Colors.purple;
  }
}

/// A widget displaying a map of USA airports with ATC/weather status.
class USAStatusMap extends StatelessWidget {
  final List<AirportStatus> airports;
  // Positions as ratios relative to the map's width/height.
  final Map<String, Offset> _airportRatios = const {
    'SFO': Offset(0.16, 0.30),
    'LAX': Offset(0.20, 0.41),
    'DEN': Offset(0.36, 0.30),
    'ORD': Offset(0.59, 0.28),
    'EWR': Offset(0.73, 0.30),
  };

  // Map airport code to coordinates.
  final Map<String, Map<String, double>> _airportCoordinates = const {
    'SFO': {'lat': 37.6213, 'lon': -122.3790},
    'LAX': {'lat': 33.9416, 'lon': -118.4085},
    'DEN': {'lat': 39.8561, 'lon': -104.6737},
    'ORD': {'lat': 41.9786, 'lon': -87.9048},
    'EWR': {'lat': 40.6925, 'lon': -74.1687},
  };

  const USAStatusMap({super.key, required this.airports});

  Future<void> _showWeatherDialog(
      BuildContext context, String airportCode) async {
    final coordinates = _airportCoordinates[airportCode];
    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Coordinates not found for this airport.')),
      );
      return;
    }
    final double lat = coordinates['lat']!;
    final double lon = coordinates['lon']!;

    final String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final double temperature = current['temperature'];
        final double windSpeed = current['windspeed'];
        final double windDirection = current['winddirection'];
        final double precipitation = current.containsKey('precipitation')
            ? current['precipitation'] ?? 0.0
            : 0.0;
        final int weatherCode = current['weathercode'];
        final String time = current['time'];
        final String weatherDescription = _mapWeatherCode(weatherCode);
        final IconData weatherIcon = _mapWeatherIcon(weatherCode);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(weatherIcon, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text('Weather at $airportCode'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.thermostat_outlined,
                              color: Colors.orange),
                          title: const Text('Temperature'),
                          trailing: Text('$temperature °C',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.water_drop,
                              color: Colors.lightBlue),
                          title: const Text('Precipitation'),
                          trailing: Text('$precipitation mm',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.air, color: Colors.green),
                          title: const Text('Wind'),
                          subtitle: Text('Direction: $windDirection°'),
                          trailing: Text('$windSpeed km/h',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(weatherIcon, color: Colors.blueAccent),
                          title: const Text('Condition'),
                          trailing: Text(weatherDescription,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.access_time,
                              color: Colors.deepPurple),
                          title: const Text('Time'),
                          trailing: Text(time,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                )
              ],
            );
          },
        );
      } else {
        String errorMessage = 'Failed to fetch weather data.';
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                )
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Exception'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              )
            ],
          );
        },
      );
    }
  }

  String _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing rain';
      case 71:
      case 73:
      case 75:
        return 'Snow fall';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  IconData _mapWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud_queue;
      case 45:
      case 48:
        return Icons.blur_on;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 56:
      case 57:
        return Icons.ac_unit;
      case 61:
      case 63:
      case 65:
        return Icons.beach_access;
      case 66:
      case 67:
        return Icons.ac_unit;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;
      case 77:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.grain;
      case 85:
      case 86:
        return Icons.ac_unit;
      case 95:
        return Icons.flash_on;
      case 96:
      case 99:
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double mapWidth = constraints.maxWidth;
        final double mapHeight = constraints.maxHeight;

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/usa_map.png',
                  fit: BoxFit.cover,
                ),
              ),
              ...airports.map((airport) {
                final ratio =
                    _airportRatios[airport.airportName] ?? Offset.zero;
                final double left = ratio.dx * mapWidth;
                final double top = ratio.dy * mapHeight;

                return Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    onTap: () =>
                        _showWeatherDialog(context, airport.airportName),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: getSeverityColor(airport.severity),
                            size: 28,
                          ),
                          Stack(
                            children: [
                              Text(
                                airport.airportName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.black,
                                ),
                              ),
                              Text(
                                airport.airportName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(2, 2),
                                      blurRadius: 1,
                                      color: Colors.black.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// A key to indicate the color meaning for each severity level.
class StatusKey extends StatelessWidget {
  const StatusKey({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _KeyIndicator(color: Colors.green, label: 'Normal'),
        SizedBox(width: 8),
        _KeyIndicator(color: Colors.yellow, label: 'Low'),
        SizedBox(width: 8),
        _KeyIndicator(color: Colors.orange, label: 'Medium'),
        SizedBox(width: 8),
        _KeyIndicator(color: Colors.red, label: 'High'),
        SizedBox(width: 8),
        _KeyIndicator(color: Colors.purple, label: 'Extreme'),
      ],
    );
  }
}

class _KeyIndicator extends StatelessWidget {
  final Color color;
  final String label;
  const _KeyIndicator({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12)),
      ],
    );
  }
}

/// A custom clipper for header decoration.
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
