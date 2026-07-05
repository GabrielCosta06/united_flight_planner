import 'dart:collection';
import 'dart:math' as math;

import '../models/flight.dart';

/// Represents an airport with a name and its corresponding code.
class Airport {
  final String name;
  final String code;
  const Airport({required this.name, required this.code});
}

class _AirportProfile {
  final String name;
  final String code;
  final String city;
  final String country;
  final bool isUnitedHub;
  final double latitude;
  final double longitude;

  const _AirportProfile({
    required this.name,
    required this.code,
    required this.city,
    required this.country,
    required this.isUnitedHub,
    required this.latitude,
    required this.longitude,
  });
}

const List<_AirportProfile> _airportProfiles = [
  _AirportProfile(
    name: 'JFK International',
    code: 'JFK',
    city: 'New York',
    country: 'United States',
    isUnitedHub: false,
    latitude: 40.6413,
    longitude: -73.7781,
  ),
  _AirportProfile(
    name: 'LAX International',
    code: 'LAX',
    city: 'Los Angeles',
    country: 'United States',
    isUnitedHub: true,
    latitude: 33.9416,
    longitude: -118.4085,
  ),
  _AirportProfile(
    name: 'Denver International Airport',
    code: 'DEN',
    city: 'Denver',
    country: 'United States',
    isUnitedHub: true,
    latitude: 39.8561,
    longitude: -104.6737,
  ),
  _AirportProfile(
    name: 'Chicago O\'Hare',
    code: 'ORD',
    city: 'Chicago',
    country: 'United States',
    isUnitedHub: true,
    latitude: 41.9742,
    longitude: -87.9073,
  ),
  _AirportProfile(
    name: 'Houston Intercontinental Airport',
    code: 'IAH',
    city: 'Houston',
    country: 'United States',
    isUnitedHub: true,
    latitude: 29.9902,
    longitude: -95.3368,
  ),
  _AirportProfile(
    name: 'Newark Liberty International Airport',
    code: 'EWR',
    city: 'Newark',
    country: 'United States',
    isUnitedHub: true,
    latitude: 40.6895,
    longitude: -74.1745,
  ),
  _AirportProfile(
    name: 'San Francisco International Airport',
    code: 'SFO',
    city: 'San Francisco',
    country: 'United States',
    isUnitedHub: true,
    latitude: 37.6213,
    longitude: -122.3790,
  ),
  _AirportProfile(
    name: 'Washington Dulles International Airport',
    code: 'IAD',
    city: 'Washington',
    country: 'United States',
    isUnitedHub: true,
    latitude: 38.9531,
    longitude: -77.4565,
  ),
  _AirportProfile(
    name: 'Antonio B. Won Pat International Airport',
    code: 'GUM',
    city: 'Guam',
    country: 'United States',
    isUnitedHub: true,
    latitude: 13.4839,
    longitude: 144.7970,
  ),
  _AirportProfile(
    name: 'Heathrow',
    code: 'LHR',
    city: 'London',
    country: 'United Kingdom',
    isUnitedHub: false,
    latitude: 51.4700,
    longitude: -0.4543,
  ),
  _AirportProfile(
    name: 'Charles de Gaulle',
    code: 'CDG',
    city: 'Paris',
    country: 'France',
    isUnitedHub: false,
    latitude: 49.0097,
    longitude: 2.5479,
  ),
  _AirportProfile(
    name: 'Frankfurt International',
    code: 'FRA',
    city: 'Frankfurt',
    country: 'Germany',
    isUnitedHub: false,
    latitude: 50.0379,
    longitude: 8.5622,
  ),
];

/// List of all airports.
const List<Airport> airportList = [
  Airport(name: 'JFK International', code: 'JFK'),
  Airport(name: 'LAX International', code: 'LAX'),
  Airport(name: 'Denver International Airport', code: 'DEN'),
  Airport(name: 'Chicago O\'Hare', code: 'ORD'),
  Airport(name: 'Houston Intercontinental Airport', code: 'IAH'),
  Airport(name: 'Newark Liberty International Airport', code: 'EWR'),
  Airport(name: 'San Francisco International Airport', code: 'SFO'),
  Airport(name: 'Washington Dulles International Airport', code: 'IAD'),
  Airport(name: 'Antonio B. Won Pat International Airport', code: 'GUM'),
  Airport(name: 'Heathrow', code: 'LHR'),
  Airport(name: 'Charles de Gaulle', code: 'CDG'),
  Airport(name: 'Frankfurt International', code: 'FRA'),
];

/// Map of airport names to their codes, generated from [airportList].
final Map<String, String> airportCodes = {
  for (var airport in airportList) airport.name: airport.code,
};

/// List of hub airports (using full airport names).
const List<String> hubs = [
  'Chicago O\'Hare',
  'Denver International Airport',
  'Houston Intercontinental Airport',
  'LAX International',
  'Newark Liberty International Airport',
  'San Francisco International Airport',
  'Washington Dulles International Airport',
  'Antonio B. Won Pat International Airport',
];

/// Enum representing flight types.
enum FlightType { domestic, international }

/// Converts a [FlightType] enum to its corresponding string.
String flightTypeToString(FlightType flightType) {
  switch (flightType) {
    case FlightType.domestic:
      return 'Domestic';
    case FlightType.international:
      return 'International';
  }
}

/// Helper to convert a flight type string (case-insensitive)
/// to the corresponding FlightType enum.
FlightType parseFlightType(String flightTypeString) {
  final normalized = flightTypeString.toLowerCase();
  if (normalized == 'domestic') {
    return FlightType.domestic;
  } else if (normalized == 'international') {
    return FlightType.international;
  } else {
    return FlightType.domestic;
  }
}

/// Generates a flight key using the origin, destination, and flight type.
/// The format is "originCode-destinationCode-flightType".
String generateFlightKey(
  String origin,
  String destination,
  FlightType flightType,
) {
  final originCode = airportCodes[origin] ?? origin;
  final destinationCode = airportCodes[destination] ?? destination;
  return '$originCode-$destinationCode-${flightTypeToString(flightType)}';
}

final DateTime scheduleStartDate = _dateOnly(DateTime.now());
final DateTime scheduleEndDate = DateTime(scheduleStartDate.year, 12, 31);

/// Fake flights database keyed by "originCode-destinationCode-flightType".
///
/// The route lists are generated lazily and deterministically from
/// [scheduleStartDate] through [scheduleEndDate], so every supported route has
/// realistic-looking service on every remaining day of the year.
final Map<String, List<Flight>> fakeFlights = _GeneratedFlightMap();

class _RouteTemplate {
  final _AirportProfile origin;
  final _AirportProfile destination;
  final FlightType flightType;
  final int routeIndex;

  const _RouteTemplate({
    required this.origin,
    required this.destination,
    required this.flightType,
    required this.routeIndex,
  });
}

class _GeneratedFlightMap extends MapBase<String, List<Flight>> {
  final Map<String, List<Flight>> _cache = {};

  @override
  Iterable<String> get keys => _routeTemplates.keys;

  @override
  List<Flight>? operator [](Object? key) {
    if (key is! String || !_routeTemplates.containsKey(key)) {
      return null;
    }
    return _cache.putIfAbsent(
      key,
      () => _generateFlightsForRoute(_routeTemplates[key]!),
    );
  }

  @override
  void operator []=(String key, List<Flight> value) {
    _cache[key] = value;
  }

  @override
  void clear() => _cache.clear();

  @override
  List<Flight>? remove(Object? key) {
    if (key is String) {
      return _cache.remove(key);
    }
    return null;
  }
}

final Map<String, _RouteTemplate> _routeTemplates = _buildRouteTemplates();

Map<String, _RouteTemplate> _buildRouteTemplates() {
  final templates = <String, _RouteTemplate>{};
  var routeIndex = 0;
  for (final origin in _airportProfiles) {
    for (final destination in _airportProfiles) {
      if (origin.code == destination.code) continue;
      final flightType = _routeFlightType(origin, destination);
      final key = generateFlightKey(origin.name, destination.name, flightType);
      templates[key] = _RouteTemplate(
        origin: origin,
        destination: destination,
        flightType: flightType,
        routeIndex: routeIndex++,
      );
    }
  }
  return templates;
}

FlightType _routeFlightType(
  _AirportProfile origin,
  _AirportProfile destination,
) {
  final isDomestic =
      origin.country == 'United States' &&
      destination.country == 'United States';
  return isDomestic ? FlightType.domestic : FlightType.international;
}

List<Flight> _generateFlightsForRoute(_RouteTemplate route) {
  final flights = <Flight>[];
  final miles = _distanceMiles(route.origin, route.destination);
  final frequency = _dailyFrequency(route, miles);
  var date = scheduleStartDate;

  while (!date.isAfter(scheduleEndDate)) {
    for (var sequence = 0; sequence < frequency; sequence++) {
      flights.add(_generateFlight(route, date, sequence, frequency, miles));
    }
    date = date.add(const Duration(days: 1));
  }

  flights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
  return flights;
}

Flight _generateFlight(
  _RouteTemplate route,
  DateTime date,
  int sequence,
  int dailyFrequency,
  double miles,
) {
  final seed = _stableHash(
    '${route.origin.code}-${route.destination.code}-${date.toIso8601String()}-$sequence',
  );
  final random = math.Random(seed);
  final departureMinute = _departureMinuteFor(route, sequence, dailyFrequency);
  final departureTime = DateTime(
    date.year,
    date.month,
    date.day,
    departureMinute ~/ 60,
    departureMinute % 60,
  );
  final blockMinutes = _blockMinutes(route.flightType, miles);
  final arrivalTime = departureTime.add(Duration(minutes: blockMinutes));
  final aircraft = _aircraftFor(route.flightType, miles, sequence, seed);
  final seats = _seatLayoutFor(aircraft);
  final loadFactor = _loadFactor(date, route.flightType, seed, sequence);
  final confirmedPassengers = _confirmedPassengers(seats, loadFactor, random);
  final checkedInPassengers = _checkedInPassengers(
    confirmedPassengers,
    departureTime,
    random,
  );
  final standbyPassengers = _standbyPassengers(
    seats.keys.toList(),
    loadFactor,
    random,
  );
  final totalSeats = seats.values.fold<int>(0, (sum, count) => sum + count);
  final bookedSeats = confirmedPassengers.values.fold<int>(
    0,
    (sum, passengers) => sum + passengers.length,
  );
  final standbyCount = standbyPassengers.values.fold<int>(
    0,
    (sum, passengers) => sum + passengers.length,
  );
  final isConnection = sequence == dailyFrequency - 1 && dailyFrequency > 1;
  final connectionAirport = isConnection ? _connectionAirport(route) : null;

  return Flight(
    originCity: route.origin.city,
    destinationCity: route.destination.city,
    flightNumber: _flightNumberFor(route.routeIndex, sequence),
    aircraft: aircraft,
    prices: _pricesFor(route.flightType, miles, seats.keys, loadFactor),
    seats: seats,
    confirmedPassengers: confirmedPassengers,
    standbyPassengers: standbyPassengers,
    checkedInPassengers: checkedInPassengers,
    departureTime: departureTime,
    arrivalTime: arrivalTime,
    origin: route.origin.name,
    destination: route.destination.name,
    originAirportCode: route.origin.code,
    destinationAirportCode: route.destination.code,
    availableSeats: math.max(0, totalSeats - bookedSeats),
    standbyCount: standbyCount,
    stops: isConnection ? '1 Stop' : 'Nonstop',
    connectionDuration: isConnection
        ? Duration(minutes: 45 + random.nextInt(55))
        : null,
    connectionDetails: connectionAirport == null
        ? null
        : 'Layover at ${connectionAirport.code} for ${45 + random.nextInt(55)} min',
    wifi: random.nextDouble() > 0.08,
    connectingPassengerIds: _connectingPassengerIds(
      confirmedPassengers,
      random,
    ),
  );
}

int _dailyFrequency(_RouteTemplate route, double miles) {
  if (route.flightType == FlightType.international) {
    final touchesUnitedHub =
        route.origin.isUnitedHub || route.destination.isUnitedHub;
    if (miles > 5000) return touchesUnitedHub ? 2 : 1;
    return touchesUnitedHub ? 2 : 1;
  }

  if (route.origin.isUnitedHub && route.destination.isUnitedHub) {
    return miles > 2500 ? 3 : 4;
  }
  if (route.origin.isUnitedHub || route.destination.isUnitedHub) {
    return 3;
  }
  return 2;
}

int _departureMinuteFor(
  _RouteTemplate route,
  int sequence,
  int dailyFrequency,
) {
  final routeOffset =
      _stableHash('${route.origin.code}-${route.destination.code}') % 38;
  final domesticBank = [375, 515, 705, 930, 1165];
  final usToEuropeBank = [1035, 1170, 1280];
  final europeToUsBank = [560, 710, 850];
  final europeBank = [480, 780, 1080];
  final pacificBank = [515, 780, 1030];

  List<int> bank;
  if (route.flightType == FlightType.domestic) {
    bank = domesticBank;
  } else if (route.origin.country == 'United States' &&
      route.destination.country != 'United States') {
    bank = route.origin.code == 'GUM' ? pacificBank : usToEuropeBank;
  } else if (route.origin.country != 'United States' &&
      route.destination.country == 'United States') {
    bank = europeToUsBank;
  } else {
    bank = europeBank;
  }

  final base = bank[sequence % bank.length];
  final spacing = sequence >= bank.length ? 95 * (sequence ~/ bank.length) : 0;
  return (base + spacing + routeOffset) % (24 * 60);
}

String _aircraftFor(
  FlightType flightType,
  double miles,
  int sequence,
  int seed,
) {
  if (flightType == FlightType.international) {
    return 'Boeing 777-200 (77u)';
  }

  final narrowBodies = [
    'Boeing 737-900',
    'Boeing 737 MAX 9',
    'Airbus A320',
    'Airbus A321',
  ];
  if (miles > 2300) {
    return sequence.isEven ? 'Boeing 737 MAX 9' : 'Airbus A321';
  }
  return narrowBodies[(seed + sequence) % narrowBodies.length];
}

Map<String, int> _seatLayoutFor(String aircraft) {
  if (aircraft.contains('777-200')) {
    return {
      'United Polaris': 50,
      'United Premium Plus': 24,
      'United Economy': 202,
    };
  }
  if (aircraft.contains('737-900')) {
    return {'United First': 20, 'United Economy': 159};
  }
  if (aircraft.contains('A320')) {
    return {
      'United First': 12,
      'United Economy Plus': 42,
      'United Economy': 96,
    };
  }
  if (aircraft.contains('A321')) {
    return {
      'United First': 20,
      'United Economy Plus': 57,
      'United Economy': 123,
    };
  }
  return {'United First': 20, 'United Economy Plus': 48, 'United Economy': 111};
}

Map<String, List<String>> _confirmedPassengers(
  Map<String, int> seats,
  double loadFactor,
  math.Random random,
) {
  final passengers = <String, List<String>>{};
  for (final entry in seats.entries) {
    final cabin = entry.key;
    final capacity = entry.value;
    final cabinAdjustment = cabin.contains('Polaris') || cabin.contains('First')
        ? -0.08
        : cabin.contains('Premium') || cabin.contains('Plus')
        ? -0.03
        : 0.02;
    final cabinLoad = _clampDouble(
      loadFactor + cabinAdjustment + (random.nextDouble() * 0.12 - 0.04),
      0.35,
      0.99,
    );
    final booked = math.min(capacity, (capacity * cabinLoad).round());
    passengers[cabin] = _passengerIds(_prefixForCabin(cabin), booked);
  }
  return passengers;
}

Map<String, List<String>> _checkedInPassengers(
  Map<String, List<String>> confirmedPassengers,
  DateTime departureTime,
  math.Random random,
) {
  final now = DateTime.now();
  final hoursUntilDeparture = departureTime.difference(now).inHours;
  final checkInRate = hoursUntilDeparture <= 0
      ? 0.94
      : hoursUntilDeparture <= 24
      ? 0.62 + random.nextDouble() * 0.28
      : 0.01 + random.nextDouble() * 0.05;

  return confirmedPassengers.map((cabin, passengers) {
    final checkedIn = math.min(
      passengers.length,
      (passengers.length * checkInRate).round(),
    );
    return MapEntry(cabin, passengers.take(checkedIn).toList());
  });
}

Map<String, List<NonRevPassenger>> _standbyPassengers(
  List<String> cabins,
  double loadFactor,
  math.Random random,
) {
  final standbyPassengers = <String, List<NonRevPassenger>>{};
  for (final cabin in cabins) {
    final pressure = loadFactor > 0.92
        ? 4
        : loadFactor > 0.82
        ? 2
        : 1;
    final count = math.max(0, pressure + random.nextInt(3) - 1);
    standbyPassengers[cabin] = List.generate(count, (index) {
      final name =
          _nonRevNames[(random.nextInt(_nonRevNames.length) + index) %
              _nonRevNames.length];
      final priority =
          _priorities[(random.nextInt(_priorities.length) + index) %
              _priorities.length];
      return NonRevPassenger(
        id: 'NR${index + 1}',
        name: name,
        priority: priority,
      );
    });
  }
  return standbyPassengers;
}

Map<String, int> _pricesFor(
  FlightType flightType,
  double miles,
  Iterable<String> cabins,
  double loadFactor,
) {
  final demandMultiplier = 0.85 + loadFactor;
  final economyBase = flightType == FlightType.domestic
      ? 90 + miles * 0.15
      : 520 + miles * 0.18;

  return {
    for (final cabin in cabins)
      cabin: _roundedFare(
        economyBase * _fareMultiplierFor(cabin) * demandMultiplier,
      ),
  };
}

double _fareMultiplierFor(String cabin) {
  if (cabin.contains('Polaris')) return 4.4;
  if (cabin.contains('First')) return 3.2;
  if (cabin.contains('Premium')) return 1.75;
  if (cabin.contains('Plus')) return 1.28;
  return 1.0;
}

int _roundedFare(double amount) => ((amount / 10).round() * 10).clamp(90, 9000);

double _loadFactor(
  DateTime date,
  FlightType flightType,
  int seed,
  int sequence,
) {
  final random = math.Random(seed + sequence * 997);
  var load = flightType == FlightType.domestic ? 0.72 : 0.78;

  if (date.weekday == DateTime.friday || date.weekday == DateTime.sunday) {
    load += 0.08;
  } else if (date.weekday == DateTime.tuesday ||
      date.weekday == DateTime.wednesday) {
    load -= 0.05;
  }

  final holidayTravel =
      (date.month == 11 && date.day >= 20) ||
      (date.month == 12 && date.day >= 15);
  if (holidayTravel) load += 0.12;

  if (date.month == 7 || date.month == 8) load += 0.05;
  if (sequence == 0) load += 0.02;
  load += random.nextDouble() * 0.18 - 0.08;

  return _clampDouble(load, 0.45, 0.99);
}

List<String> _passengerIds(String prefix, int count) {
  return List.generate(count, (index) => '$prefix${index + 1}');
}

String _prefixForCabin(String cabin) {
  if (cabin.contains('Polaris')) return 'UP';
  if (cabin.contains('Premium Plus')) return 'UPP';
  if (cabin.contains('First')) return 'UF';
  if (cabin.contains('Economy Plus')) return 'UEP';
  return 'UE';
}

List<String> _connectingPassengerIds(
  Map<String, List<String>> confirmedPassengers,
  math.Random random,
) {
  final allPassengers = confirmedPassengers.values
      .expand((ids) => ids)
      .toList();
  if (allPassengers.isEmpty) return const [];
  final count = math.min(6, math.max(1, allPassengers.length ~/ 25));
  allPassengers.shuffle(random);
  return allPassengers.take(count).toList();
}

_AirportProfile? _connectionAirport(_RouteTemplate route) {
  final candidates = _airportProfiles.where((airport) {
    if (!airport.isUnitedHub) return false;
    return airport.code != route.origin.code &&
        airport.code != route.destination.code;
  }).toList();
  if (candidates.isEmpty) return null;
  final index =
      _stableHash('${route.origin.code}-${route.destination.code}') %
      candidates.length;
  return candidates[index];
}

String _flightNumberFor(int routeIndex, int sequence) {
  final number = 100 + ((routeIndex * 7 + sequence * 17) % 8900);
  return 'UA${number.toString().padLeft(3, '0')}';
}

int _blockMinutes(FlightType flightType, double miles) {
  final cruiseSpeed = flightType == FlightType.domestic ? 485 : 515;
  final taxiPadding = flightType == FlightType.domestic ? 42 : 62;
  final minutes = (miles / cruiseSpeed * 60 + taxiPadding).round();
  return math.max(flightType == FlightType.domestic ? 70 : 95, minutes);
}

double _distanceMiles(_AirportProfile a, _AirportProfile b) {
  const earthRadiusMiles = 3958.8;
  final lat1 = _degreesToRadians(a.latitude);
  final lat2 = _degreesToRadians(b.latitude);
  final deltaLat = _degreesToRadians(b.latitude - a.latitude);
  final deltaLon = _degreesToRadians(b.longitude - a.longitude);
  final haversine =
      math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(deltaLon / 2) *
          math.sin(deltaLon / 2);
  return earthRadiusMiles *
      2 *
      math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
}

double _degreesToRadians(double degrees) => degrees * math.pi / 180;

double _clampDouble(double value, double min, double max) {
  return math.max(min, math.min(max, value));
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _stableHash(String value) {
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

const List<String> _nonRevNames = [
  'Alice Barber',
  'Bob Diana',
  'Charlie Reed',
  'Diana Patel',
  'Eve Martinez',
  'Frank Stone',
  'Grace Kim',
  'Heidi Moore',
  'Ivan Brooks',
  'Judy Chen',
  'Lena Ortiz',
  'Marcus Hill',
];

const List<String> _priorities = ['PS0E', 'SA1P', 'SA2P', 'SA3P'];

/// A repository that abstracts fetching flight data.
///
/// Currently, it uses an in-memory fake database. Later, you can easily update
/// this class to perform SQL queries or API calls without changing the business logic.
class FlightRepository {
  /// Fetch flights for the given [origin], [destination], and [flightType].
  Future<List<Flight>> fetchFlights({
    required String origin,
    required String destination,
    required FlightType flightType,
  }) async {
    final key = generateFlightKey(origin, destination, flightType);
    // Simulate network/database delay.
    await Future.delayed(const Duration(milliseconds: 500));
    return fakeFlights[key] ?? [];
  }
}

/// ==========================================================================
/// The following getters are provided for backwards compatibility.
/// Other parts of your code that reference `airports` or `flightTypes` will
/// continue to work using these definitions.
/// ==========================================================================

/// Returns a list of airport names extracted from [airportList].
List<String> get airports =>
    airportList.map((airport) => airport.name).toList();

/// Returns a list of flight type strings from the [FlightType] enum.
List<String> get flightTypes =>
    FlightType.values.map((ft) => flightTypeToString(ft)).toList();
