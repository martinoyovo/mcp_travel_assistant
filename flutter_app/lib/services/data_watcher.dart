import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/flight.dart';

class DataWatcher {
  final StreamController<List<Flight>> _flightsController =
      StreamController<List<Flight>>.broadcast();
  final StreamController<BookingConfirmation?> _bookingController =
      StreamController<BookingConfirmation?>.broadcast();

  Stream<List<Flight>> get flightsStream => _flightsController.stream;
  Stream<BookingConfirmation?> get bookingStream => _bookingController.stream;

  Timer? _pollTimer;
  String? _lastFileContent;

  void startWatching() {
    // For demo purposes, start with empty state
    _flightsController.add([]);

    if (kIsWeb) {
      // On web, we can't access the file system
      // In a real app, this would connect to a websocket or HTTP endpoint
      print('Web mode: File watching disabled. Use manual updates for demo.');
      return;
    }

    // On mobile/desktop, poll the actual file
    // ignore: prefer_const_constructors
    _pollTimer = Timer.periodic(Duration(seconds: 1), (_) => _checkFile());
    _checkFile(); // Initial check
  }

  void stopWatching() {
    _pollTimer?.cancel();
  }

  // Manual update methods for web demo
  void updateFlights(List<Flight> flights) {
    _flightsController.add(flights);
  }

  void showBookingConfirmation(BookingConfirmation booking) {
    _bookingController.add(booking);
  }

  void clearFlights() {
    _flightsController.add([]);
  }

  Future<void> _checkFile() async {
    try {
      final file = File(
          '/Users/kos14224/Documents/kyovoRepos/flight_search_tool/shared_data/flights.json');
      if (!await file.exists()) {
        return;
      }

      final content = await file.readAsString();
      if (content == _lastFileContent) {
        return; // No changes
      }

      _lastFileContent = content;

      if (content.trim().isEmpty) {
        return;
      }

      final data = jsonDecode(content) as Map<String, dynamic>;
      final action = data['action'] as String?;

      switch (action) {
        case 'search_results':
          _handleSearchResults(data);
          break;
        case 'booking_confirmed':
          _handleBookingConfirmation(data);
          break;
        case 'clear':
          _flightsController.add([]);
          break;
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  void _handleSearchResults(Map<String, dynamic> data) {
    try {
      final flightsJson = data['flights'] as List<dynamic>? ?? [];
      final flights = flightsJson
          .map((json) => Flight.fromJson(json as Map<String, dynamic>))
          .toList();

      _flightsController.add(flights);
    } catch (e) {
      print('Error parsing search results: $e');
    }
  }

  void _handleBookingConfirmation(Map<String, dynamic> data) {
    try {
      final booking = BookingConfirmation.fromJson(data);
      _bookingController.add(booking);
    } catch (e) {
      print('Error parsing booking confirmation: $e');
    }
  }

  void dispose() {
    stopWatching();
    _flightsController.close();
    _bookingController.close();
  }
}
