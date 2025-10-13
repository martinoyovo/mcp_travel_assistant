import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class FileWriter {
  static const String _dataDir = 'shared_data';
  static const String _fileName = 'flights.json';

  static Future<void> writeFlightData(Map<String, dynamic> data) async {
    try {
      final directory = Directory(_dataDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = path.join(_dataDir, _fileName);
      final file = File(filePath);
      
      data['timestamp'] = DateTime.now().toIso8601String();
      
      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      
      await file.writeAsString(jsonString);
    } catch (e) {
      stderr.writeln('Error writing to file: $e');
    }
  }

  static Future<void> writeSearchResults(List<Map<String, dynamic>> flights, Map<String, dynamic> query) async {
    final data = {
      'action': 'search_results',
      'flights': flights,
      'query': query,
    };
    await writeFlightData(data);
  }

  static Future<void> writeBookingConfirmation({
    required String confirmationCode,
    required Map<String, dynamic> flight,
    required Map<String, dynamic> passenger,
  }) async {
    final data = {
      'action': 'booking_confirmed',
      'confirmationCode': confirmationCode,
      'flight': flight,
      'passenger': passenger,
      'status': 'confirmed',
    };
    await writeFlightData(data);
  }

  static Future<void> clearData() async {
    final data = {
      'action': 'clear',
      'flights': <Map<String, dynamic>>[],
    };
    await writeFlightData(data);
  }
}