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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'flightNumber': flightNumber,
      'origin': origin,
      'originCode': originCode,
      'destination': destination,
      'destinationCode': destinationCode,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'currency': currency,
      'seats': seats,
      'class': flightClass,
    };
  }

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

  Flight copyWith({int? seats}) {
    return Flight(
      id: id,
      airline: airline,
      flightNumber: flightNumber,
      origin: origin,
      originCode: originCode,
      destination: destination,
      destinationCode: destinationCode,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      duration: duration,
      price: price,
      currency: currency,
      seats: seats ?? this.seats,
      flightClass: flightClass,
    );
  }
}