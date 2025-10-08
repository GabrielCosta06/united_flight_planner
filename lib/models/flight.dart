/// Represents a non-revenue passenger (e.g., standby or bumped).
class NonRevPassenger {
  final String id;
  final String name; // Passenger's name.
  final String priority; // E.g., "High", "Medium", "Low".

  NonRevPassenger({
    required this.id,
    required this.name,
    required this.priority,
  });

  /// Converts a NonRevPassenger instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priority': priority,
      };

  /// Creates a NonRevPassenger instance from a JSON map.
  factory NonRevPassenger.fromJson(Map<String, dynamic> json) {
    return NonRevPassenger(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: json['priority'] as String,
    );
  }
}

/// Represents a flight with details like schedule, pricing, seating, and passengers.
class Flight {
  final String flightNumber;
  final String aircraft;
  final Map<String, int> prices;
  final Map<String, int> seats;
  final Map<String, List<String>> confirmedPassengers;
  final Map<String, List<NonRevPassenger>> standbyPassengers;
  final Map<String, List<String>> checkedInPassengers;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String origin;
  final String destination;
  final String destinationAirportCode;
  final String originAirportCode;
  final int availableSeats;
  final int standbyCount;
  final String stops;
  final Duration? connectionDuration;
  final String? connectionDetails;
  final bool wifi;
  // New field: list of passenger IDs that are connecting.
  final List<String>? connectingPassengerIds;
  final String? originCity;
  final String? destinationCity;

  Flight({
    required this.flightNumber,
    required this.aircraft,
    required this.prices,
    required this.seats,
    required this.confirmedPassengers,
    required this.standbyPassengers,
    required this.checkedInPassengers,
    required this.departureTime,
    required this.arrivalTime,
    required this.origin,
    required this.destination,
    required this.availableSeats,
    required this.standbyCount,
    required this.originAirportCode,
    required this.destinationAirportCode,
    required this.stops,
    this.connectionDuration,
    this.connectionDetails,
    required this.wifi,
    this.connectingPassengerIds,
    this.originCity,
    this.destinationCity,
  });

  /// Converts a Flight instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'flightNumber': flightNumber,
        'aircraft': aircraft,
        'prices': prices,
        'seats': seats,
        'confirmedPassengers': confirmedPassengers,
        'standbyPassengers': standbyPassengers.map(
          (key, value) => MapEntry(key, value.map((p) => p.toJson()).toList()),
        ),
        'checkedInPassengers': checkedInPassengers,
        'departureTime': departureTime.toIso8601String(),
        'arrivalTime': arrivalTime.toIso8601String(),
        'origin': origin,
        'destination': destination,
        'availableSeats': availableSeats,
        'standbyCount': standbyCount,
        'stops': stops,
        'connectionDuration': connectionDuration?.inSeconds,
        'connectionDetails': connectionDetails,
        'wifi': wifi,
        'connectingPassengerIds': connectingPassengerIds,
      };

  /// Creates a Flight instance from a JSON map.
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightNumber: json['flightNumber'] as String,
      aircraft: json['aircraft'] as String,
      prices: Map<String, int>.from(json['prices']),
      seats: Map<String, int>.from(json['seats']),
      confirmedPassengers: (json['confirmedPassengers'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, List<String>.from(value as List))),
      standbyPassengers:
          (json['standbyPassengers'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List)
              .map((p) => NonRevPassenger.fromJson(p as Map<String, dynamic>))
              .toList(),
        ),
      ),
      checkedInPassengers: (json['checkedInPassengers'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, List<String>.from(value as List))),
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      originAirportCode: json['originAirportCode'] as String,
      destinationAirportCode: json['destinationAirportCode'] as String,
      availableSeats: json['availableSeats'] as int,
      standbyCount: json['standbyCount'] as int,
      stops: json['stops'] as String,
      connectionDuration: json['connectionDuration'] != null
          ? Duration(seconds: json['connectionDuration'] as int)
          : null,
      connectionDetails: json['connectionDetails'] as String?,
      wifi: json['wifi'] as bool,
      connectingPassengerIds: json['connectingPassengerIds'] != null
          ? List<String>.from(json['connectingPassengerIds'])
          : null,
    );
  }
}
