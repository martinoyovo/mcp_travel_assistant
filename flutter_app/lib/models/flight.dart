class Flight {
  final String id;
  final String airline;
  final String flightNumber;
  final String origin;
  final String originCode;
  final String destination;
  final String destinationCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;
  final double price;
  final String currency;
  final int seats;
  final String flightClass;

  Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.origin,
    required this.originCode,
    required this.destination,
    required this.destinationCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.seats,
    required this.flightClass,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      airline: json['airline'],
      flightNumber: json['flightNumber'],
      origin: json['origin'],
      originCode: json['originCode'],
      destination: json['destination'],
      destinationCode: json['destinationCode'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      duration: json['duration'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      seats: json['seats'],
      flightClass: json['class'],
    );
  }
}

class BookingConfirmation {
  final String confirmationCode;
  final Flight flight;
  final String passengerName;
  final String? email;
  final DateTime timestamp;

  BookingConfirmation({
    required this.confirmationCode,
    required this.flight,
    required this.passengerName,
    this.email,
    required this.timestamp,
  });

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) {
    return BookingConfirmation(
      confirmationCode: json['confirmationCode'],
      flight: Flight.fromJson(json['flight']),
      passengerName: json['passenger']['name'],
      email: json['passenger']['email'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}