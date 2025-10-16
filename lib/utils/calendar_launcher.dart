import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/flight.dart';

/// Builds a Google Calendar event URL for the provided [flight] and attempts to open it.
///
/// Returns `true` if the URL could be launched, otherwise `false`.
Future<bool> launchFlightCalendarEvent(Flight flight) async {
  final startUtc = flight.departureTime.toUtc();
  final endUtc = flight.arrivalTime.toUtc();

  final dateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");
  final dates =
      '${dateFormat.format(startUtc)}/${dateFormat.format(endUtc)}';

  final flightName =
      'Flight ${flight.flightNumber} ${flight.originAirportCode}-${flight.destinationAirportCode}';
  final details =
      'Flight ${flight.flightNumber} from ${flight.origin} to ${flight.destination}.';

  final uri = Uri.https(
    'calendar.google.com',
    '/calendar/render',
    {
      'action': 'TEMPLATE',
      'text': flightName,
      'dates': dates,
      'details': details,
      'location': '${flight.originAirportCode} Airport',
    },
  );

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
