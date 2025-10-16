import 'package:flutter/foundation.dart';

import '../models/flight.dart';

/// A booking service to manage seat assignments on flights.
class BookingService {
  /// Books a seat for the given [flight] in the [seatClass] for [passengerId].
  ///
  /// Checks that:
  /// - The seat class exists.
  /// - The number of confirmed bookings in the class is less than its capacity.
  ///
  /// Returns true if booking succeeds, false otherwise.
  bool bookSeat(Flight flight, String seatClass, String passengerId) {
    if (!flight.seats.containsKey(seatClass)) {
      debugPrint('Invalid seat class: $seatClass');
      return false;
    }
    // Ensure the list exists for this seat class.
    flight.confirmedPassengers.putIfAbsent(seatClass, () => []);
    List<String> confirmed = flight.confirmedPassengers[seatClass]!;

    int capacity = flight.seats[seatClass]!;
    if (confirmed.length >= capacity) {
      debugPrint('No available seats in $seatClass.');
      return false;
    }

    confirmed.add(passengerId);
    debugPrint(
        'Seat booked for passenger $passengerId in $seatClass on flight ${flight.flightNumber}.');
    return true;
  }

  /// Unbooks (cancels) a seat for the given [flight] in the [seatClass] for [passengerId].
  ///
  /// Returns true if unbooking succeeds, false if the passenger was not found.
  bool unbookSeat(Flight flight, String seatClass, String passengerId) {
    if (!flight.seats.containsKey(seatClass)) {
      debugPrint('Invalid seat class: $seatClass');
      return false;
    }
    // Ensure the list exists for this seat class.
    flight.confirmedPassengers.putIfAbsent(seatClass, () => []);
    List<String> confirmed = flight.confirmedPassengers[seatClass]!;

    if (!confirmed.contains(passengerId)) {
      debugPrint('Passenger $passengerId not found in $seatClass bookings.');
      return false;
    }

    confirmed.remove(passengerId);
    debugPrint(
        'Seat unbooked for passenger $passengerId in $seatClass on flight ${flight.flightNumber}.');
    return true;
  }

  /// Marks [passengerId] as checked in for the given [flight] and [seatClass].
  ///
  /// The passenger must already have a confirmed booking in the same cabin.
  /// Returns `true` if the check-in succeeds, otherwise `false`.
  bool checkInPassenger(Flight flight, String seatClass, String passengerId) {
    if (!flight.seats.containsKey(seatClass)) {
      debugPrint('Invalid seat class: $seatClass');
      return false;
    }

    final confirmedPassengers =
        flight.confirmedPassengers[seatClass] ?? <String>[];
    if (!confirmedPassengers.contains(passengerId)) {
      debugPrint(
          'Passenger $passengerId does not have a confirmed seat in $seatClass.');
      return false;
    }

    flight.checkedInPassengers.putIfAbsent(seatClass, () => []);
    final checkedIn = flight.checkedInPassengers[seatClass]!;

    if (checkedIn.contains(passengerId)) {
      debugPrint(
          'Passenger $passengerId is already checked in for flight ${flight.flightNumber}.');
      return false;
    }

    checkedIn.add(passengerId);
    debugPrint(
        'Passenger $passengerId checked in for $seatClass on flight ${flight.flightNumber}.');
    return true;
  }
}
