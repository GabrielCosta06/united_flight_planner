import '../models/flight.dart';

/// Represents an airport with a name and its corresponding code.
class Airport {
  final String name;
  final String code;
  const Airport({required this.name, required this.code});
}

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
enum FlightType { Domestic, International }

/// Converts a [FlightType] enum to its corresponding string.
String flightTypeToString(FlightType flightType) {
  switch (flightType) {
    case FlightType.Domestic:
      return 'Domestic';
    case FlightType.International:
      return 'International';
  }
}

/// Helper to convert a flight type string (case-insensitive)
/// to the corresponding FlightType enum.
FlightType parseFlightType(String flightTypeString) {
  final normalized = flightTypeString.toLowerCase();
  if (normalized == 'domestic') {
    return FlightType.Domestic;
  } else if (normalized == 'international') {
    return FlightType.International;
  } else {
    // default to Domestic if unknown
    return FlightType.Domestic;
  }
}

/// Generates a flight key using the origin, destination, and flight type.
/// The format is "originCode-destinationCode-flightType".
String generateFlightKey(
    String origin, String destination, FlightType flightType) {
  final originCode = airportCodes[origin] ?? origin;
  final destinationCode = airportCodes[destination] ?? destination;
  return '$originCode-$destinationCode-${flightTypeToString(flightType)}';
}

/// Fake flights database keyed by "originCode-destinationCode-flightType".
final Map<String, List<Flight>> fakeFlights = {
  // Merged flights for Newark Liberty International Airport -> Houston Intercontinental Airport (Domestic)
  generateFlightKey('Newark Liberty International Airport',
      'Houston Intercontinental Airport', FlightType.Domestic): [
    // Flight UA101: Nonstop with Wi-Fi, using Boeing 737-900.
    Flight(
      originCity: 'Newark',
      destinationCity: 'Houston',
      flightNumber: 'UA101',
      aircraft: 'Boeing 737-900',
      prices: {
        'United First': 1200,
        'United Economy': 300,
      },
      seats: {
        'United First': 20,
        'United Economy': 117,
      },
      confirmedPassengers: {
        'United First': [
          'UF1',
          'UF2',
          'UF3',
          'UF4',
          'UF5',
          'UF6',
          'UF7',
          'UF8',
          'UF9',
          'UF10'
        ],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
          'UE9',
          'UE10',
          'UE11',
          'UE12',
          'UE13',
          'UE14',
          'UE15',
          'UE16',
          'UE17',
          'UE18',
          'UE19',
          'UE20',
          'UE21',
          'UE22',
          'UE23',
          'UE24',
          'UE25',
          'UE26',
          'UE27',
          'UE28',
          'UE29',
          'UE30',
          'UE31',
          'UE32',
          'UE33',
          'UE34',
          'UE35',
          'UE36',
          'UE37',
          'UE38',
          'UE39',
          'UE40'
        ],
      },
      standbyPassengers: {
        'United First': [
          NonRevPassenger(id: 'NR1', name: 'Alice Barber', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Bob Diana', priority: 'SA1P'),
        ],
        'United Economy': [
          NonRevPassenger(id: 'NR1', name: 'Charlie', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Diana', priority: 'SA1P'),
        ],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4', 'UF5'],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8'
        ],
      },
      departureTime: DateTime(2025, 4, 15, 8, 0),
      arrivalTime: DateTime(2025, 4, 15, 11, 0),
      origin: 'Newark Liberty International Airport',
      destination: 'Houston Intercontinental Airport',
      originAirportCode: airportCodes['Newark Liberty International Airport']!,
      destinationAirportCode: airportCodes['Houston Intercontinental Airport']!,
      availableSeats: 87,
      standbyCount: 4,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
      connectingPassengerIds: ['UF3', 'UF6'],
    ),
    // Flight UA102: 1-stop without Wi-Fi, using Boeing 737-900.
    Flight(
      flightNumber: 'UA102',
      aircraft: 'Boeing 737-900',
      prices: {
        'United First': 1300,
        'United Economy': 320,
      },
      seats: {
        'United First': 20,
        'United Economy': 117,
      },
      confirmedPassengers: {
        'United First': [
          'UF1',
          'UF2',
          'UF3',
          'UF4',
          'UF5',
          'UF6',
          'UF7',
          'UF8'
        ],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
          'UE9',
          'UE10',
          'UE11',
          'UE12',
          'UE13',
          'UE14',
          'UE15',
          'UE16',
          'UE17',
          'UE18',
          'UE19',
          'UE20'
        ],
      },
      standbyPassengers: {
        'United First': [
          NonRevPassenger(id: 'NR1', name: 'Eve', priority: 'PS0E'),
        ],
        'United Economy': [
          NonRevPassenger(id: 'NR1', name: 'Frank', priority: 'SA1P'),
        ],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2', 'UF3'],
        'United Economy': ['UE1', 'UE2', 'UE3'],
      },
      departureTime: DateTime(2025, 4, 15, 9, 0),
      arrivalTime: DateTime(2025, 4, 15, 13, 0),
      origin: 'Newark Liberty International Airport',
      destination: 'Houston Intercontinental Airport',
      originAirportCode: airportCodes['Newark Liberty International Airport']!,
      destinationAirportCode: airportCodes['Houston Intercontinental Airport']!,
      availableSeats: 109,
      standbyCount: 2,
      stops: '1 Stop',
      connectionDuration: const Duration(minutes: 45),
      connectionDetails: 'Layover at ORD for 45 min',
      wifi: false,
      connectingPassengerIds: ['UF2', 'UF4'],
    ),
    // Flight UA103: Nonstop with Wi-Fi, using Boeing 737-900.
    Flight(
      originCity: 'Newark',
      destinationCity: 'Houston',
      flightNumber: 'UA103',
      aircraft: 'Boeing 737-900',
      prices: {
        'United First': 1200,
        'United Economy': 300,
      },
      seats: {
        'United First': 20,
        'United Economy': 117,
      },
      confirmedPassengers: {
        'United First': [
          'UF1',
          'UF2',
          'UF3',
          'UF4',
          'UF5',
          'UF6',
          'UF7',
          'UF8',
          'UF9',
          'UF10'
        ],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
          'UE9',
          'UE10',
          'UE11',
          'UE12',
          'UE13',
          'UE14',
          'UE15',
          'UE16',
          'UE17',
          'UE18',
          'UE19',
          'UE20',
          'UE21',
          'UE22',
          'UE23',
          'UE24',
          'UE25',
          'UE26',
          'UE27',
          'UE28',
          'UE29',
          'UE30',
          'UE31',
          'UE32',
          'UE33',
          'UE34',
          'UE35',
          'UE36',
          'UE37',
          'UE38',
          'UE39',
          'UE40'
        ],
      },
      standbyPassengers: {
        'United First': [
          NonRevPassenger(id: 'NR1', name: 'Alice Barber', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Bob Diana', priority: 'SA1P'),
        ],
        'United Economy': [
          NonRevPassenger(id: 'NR1', name: 'Charlie', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Diana', priority: 'SA1P'),
        ],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4', 'UF5'],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
        ],
      },
      departureTime: DateTime(2025, 4, 15, 8, 0),
      arrivalTime: DateTime(2025, 4, 15, 11, 0),
      origin: 'Newark Liberty International Airport',
      destination: 'Houston Intercontinental Airport',
      originAirportCode: airportCodes['Newark Liberty International Airport']!,
      destinationAirportCode: airportCodes['Houston Intercontinental Airport']!,
      availableSeats: 30,
      standbyCount: 4,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
      connectingPassengerIds: ['UF3', 'UF6'],
    ),
    // Flight UA104: Duplicated UA103 with additional passengers.
    Flight(
      originCity: 'Newark',
      destinationCity: 'Houston',
      flightNumber: 'UA104',
      aircraft: 'Boeing 737-900',
      prices: {
        'United First': 1200,
        'United Economy': 300,
      },
      seats: {
        'United First': 20,
        'United Economy': 117,
      },
      confirmedPassengers: {
        'United First': [
          'UF1',
          'UF2',
          'UF3',
          'UF4',
          'UF5',
          'UF6',
          'UF7',
          'UF8',
          'UF9',
          'UF10',
          'UF11',
          'UF12',
          'UF13',
          'UF14',
          'UF15',
          'UF16',
          'UF17',
          'UF18',
          'UF19',
          'UF20'
        ],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
          'UE9',
          'UE10',
          'UE11',
          'UE12',
          'UE13',
          'UE14',
          'UE15',
          'UE16',
          'UE17',
          'UE18',
          'UE19',
          'UE20',
          'UE21',
          'UE22',
          'UE23',
          'UE24',
          'UE25',
          'UE26',
          'UE27',
          'UE28',
          'UE29',
          'UE30',
          'UE31',
          'UE32',
          'UE33',
          'UE34',
          'UE35',
          'UE36',
          'UE37',
          'UE38',
          'UE39',
          'UE40',
          'UE41',
          'UE42',
          'UE43',
          'UE44',
          'UE45',
          'UE46',
          'UE47',
          'UE48',
          'UE49',
          'UE50',
          'UE51',
          'UE52',
          'UE53',
          'UE54',
          'UE55',
          'UE56',
          'UE57',
          'UE58',
          'UE59',
          'UE60',
          'UE61',
          'UE62',
          'UE63',
          'UE64',
          'UE65',
          'UE66',
          'UE67',
          'UE68',
          'UE69',
          'UE70',
          'UE71',
          'UE72',
          'UE73',
          'UE74',
          'UE75',
          'UE76',
          'UE77',
          'UE78',
          'UE79',
          'UE80',
          'UE81',
          'UE82',
          'UE83',
          'UE84',
          'UE85',
          'UE86',
          'UE87',
          'UE88',
          'UE89',
          'UE90',
          'UE91',
          'UE92',
          'UE93',
          'UE94',
          'UE95',
          'UE96',
          'UE97',
        ],
      },
      standbyPassengers: {
        'United First': [
          NonRevPassenger(id: 'NR1', name: 'Alice Barber', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Bob Diana', priority: 'SA1P'),
        ],
        'United Economy': [
          NonRevPassenger(id: 'NR1', name: 'Charlie', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Diana', priority: 'SA1P'),
        ],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4', 'UF5'],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
        ],
      },
      departureTime: DateTime(2025, 4, 15, 8, 0),
      arrivalTime: DateTime(2025, 4, 15, 11, 0),
      origin: 'Newark Liberty International Airport',
      destination: 'Houston Intercontinental Airport',
      originAirportCode: airportCodes['Newark Liberty International Airport']!,
      destinationAirportCode: airportCodes['Houston Intercontinental Airport']!,
      availableSeats: 5,
      standbyCount: 4,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
      connectingPassengerIds: ['UF3', 'UF6'],
    ),
    // Flight UA434: Additional flight entry merged into the same key.
    Flight(
      originCity: 'Newark',
      destinationCity: 'Houston',
      flightNumber: 'UA434',
      aircraft: 'Boeing 737-900',
      prices: {
        'United First': 1200,
        'United Economy': 300,
      },
      seats: {
        'United First': 20,
        'United Economy': 117,
      },
      confirmedPassengers: {
        'United First': [
          'UF1',
          'UF2',
          'UF3',
          'UF4',
          'UF5',
          'UF6',
          'UF7',
          'UF8',
          'UF9',
          'UF10'
        ],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
        ],
      },
      standbyPassengers: {
        'United First': [
          NonRevPassenger(id: 'NR1', name: 'Alice Barber', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Bob Diana', priority: 'SA1P'),
        ],
        'United Economy': [
          NonRevPassenger(id: 'NR1', name: 'Charlie', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Diana', priority: 'SA1P'),
        ],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4', 'UF5'],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8'
        ],
      },
      departureTime: DateTime(2025, 3, 27, 8, 0),
      arrivalTime: DateTime(2025, 3, 27, 11, 0),
      origin: 'Newark Liberty International Airport',
      destination: 'Houston Intercontinental Airport',
      originAirportCode: airportCodes['Newark Liberty International Airport']!,
      destinationAirportCode: airportCodes['Houston Intercontinental Airport']!,
      availableSeats: 87,
      standbyCount: 4,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
      connectingPassengerIds: ['UF3', 'UF6'],
    ),
  ],
  generateFlightKey('Washington Dulles International Airport',
      'Frankfurt International', FlightType.International): [
    // Flight UA201: Nonstop international flight with Wi-Fi, using Boeing 777-200 (77u).
    Flight(
      originCity: 'Washington',
      destinationCity: 'Frankfurt',
      flightNumber: 'UA201',
      aircraft: 'Boeing 777-200 (77u)',
      prices: {
        'United Polaris': 4000,
        'United Premium Plus': 2500,
        'United Economy': 1500,
      },
      seats: {
        'United Polaris': 20,
        'United Premium Plus': 40,
        'United Economy': 250,
      },
      confirmedPassengers: {
        'United Polaris': [
          'UP1',
          'UP2',
          'UP3',
          'UP4',
          'UP5',
          'UP6',
          'UP7',
          'UP8',
          'UP9',
          'UP10'
        ],
        'United Premium Plus': [
          'UPP1',
          'UPP2',
          'UPP3',
          'UPP4',
          'UPP5',
          'UPP6',
          'UPP7',
          'UPP8',
          'UPP9',
          'UPP10',
          'UPP11',
          'UPP12',
          'UPP13',
          'UPP14',
          'UPP15',
          'UPP16',
          'UPP17',
          'UPP18',
          'UPP19',
          'UPP20'
        ],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
          'UE9',
          'UE10',
          'UE11',
          'UE12',
          'UE13',
          'UE14',
          'UE15',
          'UE16',
          'UE17',
          'UE18',
          'UE19',
          'UE20',
          'UE21',
          'UE22',
          'UE23',
          'UE24',
          'UE25',
          'UE26',
          'UE27',
          'UE28',
          'UE29',
          'UE30',
          'UE31',
          'UE32',
          'UE33',
          'UE34',
          'UE35',
          'UE36',
          'UE37',
          'UE38',
          'UE39',
          'UE40',
          'UE41',
          'UE42',
          'UE43',
          'UE44',
          'UE45',
          'UE46',
          'UE47',
          'UE48',
          'UE49',
          'UE50'
        ],
      },
      standbyPassengers: {
        'United Polaris': [
          NonRevPassenger(id: 'NR1', name: 'Grace', priority: 'PS0E'),
        ],
        'United Premium Plus': [
          NonRevPassenger(id: 'NR1', name: 'Heidi', priority: 'PS0E'),
        ],
        'United Economy': [
          NonRevPassenger(id: 'NR1', name: 'Ivan', priority: 'PS0E'),
          NonRevPassenger(id: 'NR2', name: 'Judy', priority: 'SA1P'),
        ],
      },
      checkedInPassengers: {
        'United Polaris': ['UP1', 'UP2', 'UP3', 'UP4', 'UP5'],
        'United Premium Plus': ['UPP1', 'UPP2', 'UPP3', 'UPP4', 'UPP5', 'UPP6'],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8',
          'UE9',
          'UE10'
        ],
      },
      departureTime: DateTime(2025, 4, 16, 19, 30),
      arrivalTime: DateTime(2025, 4, 17, 10, 30),
      origin: 'Washington Dulles International Airport',
      destination: 'Frankfurt International',
      originAirportCode:
          airportCodes['Washington Dulles International Airport']!,
      destinationAirportCode: airportCodes['Frankfurt International']!,
      availableSeats: 230,
      standbyCount: 4,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
    ),
  ],
  generateFlightKey('Chicago O\'Hare', 'Houston Intercontinental Airport',
      FlightType.Domestic): [
    // Flight UA301.
    Flight(
      originCity: 'Chicago',
      destinationCity: 'Houston',
      flightNumber: 'UA301',
      aircraft: 'Airbus A320',
      prices: {
        'United First': 1100,
        'United Economy': 280,
      },
      seats: {
        'United First': 16,
        'United Economy': 140,
      },
      confirmedPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4'],
        'United Economy': ['UE1', 'UE2', 'UE3', 'UE4', 'UE5'],
      },
      standbyPassengers: {
        'United First': [],
        'United Economy': [],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2'],
        'United Economy': ['UE1', 'UE2', 'UE3'],
      },
      departureTime: DateTime(2025, 4, 10, 7, 30),
      arrivalTime: DateTime(2025, 4, 10, 9, 30),
      origin: 'Chicago O\'Hare',
      destination: 'Houston Intercontinental Airport',
      originAirportCode: airportCodes['Chicago O\'Hare']!,
      destinationAirportCode: airportCodes['Houston Intercontinental Airport']!,
      availableSeats: 140,
      standbyCount: 0,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
    ),
  ],
  generateFlightKey('Denver International Airport',
      'San Francisco International Airport', FlightType.Domestic): [
    // Flight UA302.
    Flight(
      originCity: 'Denver',
      destinationCity: 'San Francisco',
      flightNumber: 'UA302',
      aircraft: 'Boeing 737 MAX',
      prices: {
        'United First': 1150,
        'United Economy': 290,
      },
      seats: {
        'United First': 18,
        'United Economy': 130,
      },
      confirmedPassengers: {
        'United First': ['UF1', 'UF2', 'UF3'],
        'United Economy': ['UE1', 'UE2', 'UE3', 'UE4', 'UE5', 'UE6'],
      },
      standbyPassengers: {
        'United First': [],
        'United Economy': [],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2'],
        'United Economy': ['UE1', 'UE2', 'UE3'],
      },
      departureTime: DateTime(2025, 4, 11, 8, 15),
      arrivalTime: DateTime(2025, 4, 11, 10, 15),
      origin: 'Denver International Airport',
      destination: 'San Francisco International Airport',
      originAirportCode: airportCodes['Denver International Airport']!,
      destinationAirportCode:
          airportCodes['San Francisco International Airport']!,
      availableSeats: 112,
      standbyCount: 0,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
    ),
  ],
  generateFlightKey('LAX International', 'Newark Liberty International Airport',
      FlightType.Domestic): [
    // Flight UA303.
    Flight(
      originCity: 'Los Angeles',
      destinationCity: 'Newark',
      flightNumber: 'UA303',
      aircraft: 'Boeing 777-300ER',
      prices: {
        'United First': 1400,
        'United Economy': 330,
      },
      seats: {
        'United First': 22,
        'United Economy': 160,
      },
      confirmedPassengers: {
        'United First': ['UF1', 'UF2', 'UF3'],
        'United Economy': ['UE1', 'UE2', 'UE3', 'UE4', 'UE5', 'UE6', 'UE7'],
      },
      standbyPassengers: {
        'United First': [],
        'United Economy': [],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2'],
        'United Economy': ['UE1', 'UE2', 'UE3'],
      },
      departureTime: DateTime(2025, 4, 12, 12, 0),
      arrivalTime: DateTime(2025, 4, 12, 20, 0),
      origin: 'LAX International',
      destination: 'Newark Liberty International Airport',
      originAirportCode: airportCodes['LAX International']!,
      destinationAirportCode:
          airportCodes['Newark Liberty International Airport']!,
      availableSeats: 138,
      standbyCount: 0,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
    ),
  ],
  generateFlightKey('Houston Intercontinental Airport',
      'Washington Dulles International Airport', FlightType.Domestic): [
    // Flight UA304.
    Flight(
      originCity: 'Houston',
      destinationCity: 'Washington',
      flightNumber: 'UA304',
      aircraft: 'Airbus A321',
      prices: {
        'United First': 1250,
        'United Economy': 310,
      },
      seats: {
        'United First': 18,
        'United Economy': 145,
      },
      confirmedPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4'],
        'United Economy': ['UE1', 'UE2', 'UE3', 'UE4', 'UE5', 'UE6'],
      },
      standbyPassengers: {
        'United First': [],
        'United Economy': [],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2'],
        'United Economy': ['UE1', 'UE2', 'UE3'],
      },
      departureTime: DateTime(2025, 4, 13, 10, 0),
      arrivalTime: DateTime(2025, 4, 13, 14, 0),
      origin: 'Houston Intercontinental Airport',
      destination: 'Washington Dulles International Airport',
      originAirportCode: airportCodes['Houston Intercontinental Airport']!,
      destinationAirportCode:
          airportCodes['Washington Dulles International Airport']!,
      availableSeats: 135,
      standbyCount: 0,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
    ),
  ],
  generateFlightKey('San Francisco International Airport', 'Chicago O\'Hare',
      FlightType.Domestic): [
    // Flight UA305.
    Flight(
      originCity: 'San Francisco',
      destinationCity: 'Chicago',
      flightNumber: 'UA305',
      aircraft: 'Boeing 787 Dreamliner',
      prices: {
        'United First': 1500,
        'United Economy': 350,
      },
      seats: {
        'United First': 20,
        'United Economy': 170,
      },
      confirmedPassengers: {
        'United First': ['UF1', 'UF2', 'UF3', 'UF4', 'UF5'],
        'United Economy': [
          'UE1',
          'UE2',
          'UE3',
          'UE4',
          'UE5',
          'UE6',
          'UE7',
          'UE8'
        ],
      },
      standbyPassengers: {
        'United First': [],
        'United Economy': [],
      },
      checkedInPassengers: {
        'United First': ['UF1', 'UF2', 'UF3'],
        'United Economy': ['UE1', 'UE2', 'UE3', 'UE4'],
      },
      departureTime: DateTime(2025, 4, 14, 14, 30),
      arrivalTime: DateTime(2025, 4, 14, 18, 30),
      origin: 'San Francisco International Airport',
      destination: 'Chicago O\'Hare',
      originAirportCode: airportCodes['San Francisco International Airport']!,
      destinationAirportCode: airportCodes['Chicago O\'Hare']!,
      availableSeats: 162,
      standbyCount: 0,
      stops: 'Nonstop',
      connectionDuration: null,
      connectionDetails: null,
      wifi: true,
    ),
  ],
};

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
