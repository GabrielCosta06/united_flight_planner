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
      print('Invalid seat class: $seatClass');
      return false;
    }
    // Ensure the list exists for this seat class.
    flight.confirmedPassengers.putIfAbsent(seatClass, () => []);
    List<String> confirmed = flight.confirmedPassengers[seatClass]!;

    int capacity = flight.seats[seatClass]!;
    if (confirmed.length >= capacity) {
      print('No available seats in $seatClass.');
      return false;
    }

    confirmed.add(passengerId);
    print(
        'Seat booked for passenger $passengerId in $seatClass on flight ${flight.flightNumber}.');
    return true;
  }

  /// Unbooks (cancels) a seat for the given [flight] in the [seatClass] for [passengerId].
  ///
  /// Returns true if unbooking succeeds, false if the passenger was not found.
  bool unbookSeat(Flight flight, String seatClass, String passengerId) {
    if (!flight.seats.containsKey(seatClass)) {
      print('Invalid seat class: $seatClass');
      return false;
    }
    // Ensure the list exists for this seat class.
    flight.confirmedPassengers.putIfAbsent(seatClass, () => []);
    List<String> confirmed = flight.confirmedPassengers[seatClass]!;

    if (!confirmed.contains(passengerId)) {
      print('Passenger $passengerId not found in $seatClass bookings.');
      return false;
    }

    confirmed.remove(passengerId);
    print(
        'Seat unbooked for passenger $passengerId in $seatClass on flight ${flight.flightNumber}.');
    return true;
  }
}
