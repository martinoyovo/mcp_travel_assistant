import 'dart:io';
import 'dart:math';
import 'dart:convert';
import '../lib/data/mock_flights.dart';
import '../lib/services/file_writer.dart';

void main() async {
  // Simple STDIO MCP server implementation
  while (true) {
    try {
      final line = stdin.readLineSync();
      if (line == null) break;
      
      final request = jsonDecode(line) as Map<String, dynamic>;
      
      if (request['method'] == 'tools/list') {
        await _handleListTools(request);
      } else if (request['method'] == 'tools/call') {
        await _handleToolCall(request);
      } else if (request['method'] == 'initialize') {
        await _handleInitialize(request);
      }
    } catch (e) {
      stderr.writeln('Error processing request: $e');
    }
  }
}

Future<void> _handleInitialize(Map<String, dynamic> request) async {
  final response = {
    'jsonrpc': '2.0',
    'id': request['id'],
    'result': {
      'protocolVersion': '2025-03-26',
      'capabilities': {
        'tools': {},
      },
      'serverInfo': {
        'name': 'travel-assistant-mcp',
        'version': '1.0.0',
      },
    },
  };
  
  stdout.writeln(jsonEncode(response));
}

Future<void> _handleListTools(Map<String, dynamic> request) async {
  final tools = [
    {
      'name': 'search_flights',
      'description': 'Search for flights between two cities with optional filters',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'origin': {
            'type': 'string',
            'description': 'Departure city or airport code',
          },
          'destination': {
            'type': 'string',
            'description': 'Arrival city or airport code',
          },
          'date': {
            'type': 'string',
            'description': 'Preferred travel date YYYY-MM-DD (optional)',
          },
          'max_price': {
            'type': 'number',
            'description': 'Maximum price in USD (optional)',
          },
          'airline': {
            'type': 'string',
            'description': 'Preferred airline (optional)',
          },
        },
        'required': ['origin', 'destination'],
      },
    },
    {
      'name': 'get_flight_details',
      'description': 'Get complete details for a specific flight',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'flight_id': {
            'type': 'string',
            'description': 'Flight ID like FL001',
          },
        },
        'required': ['flight_id'],
      },
    },
    {
      'name': 'book_flight',
      'description': 'Simulate booking a flight',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'flight_id': {
            'type': 'string',
            'description': 'Flight to book',
          },
          'passenger_name': {
            'type': 'string',
            'description': 'Passenger full name',
          },
          'email': {
            'type': 'string',
            'description': 'Contact email (optional)',
          },
        },
        'required': ['flight_id', 'passenger_name'],
      },
    },
    {
      'name': 'clear_search',
      'description': 'Clear current search results from the display',
      'inputSchema': {
        'type': 'object',
        'properties': {},
      },
    },
    {
      'name': 'get_user_preferences',
      'description': 'Get mock user travel preferences',
      'inputSchema': {
        'type': 'object',
        'properties': {},
      },
    },
  ];

  final response = {
    'jsonrpc': '2.0',
    'id': request['id'],
    'result': {
      'tools': tools,
    },
  };
  
  stdout.writeln(jsonEncode(response));
}

Future<void> _handleToolCall(Map<String, dynamic> request) async {
  try {
    final params = request['params'] as Map<String, dynamic>;
    final toolName = params['name'] as String;
    final args = params['arguments'] as Map<String, dynamic>? ?? {};
    
    Map<String, dynamic> result;
    
    switch (toolName) {
      case 'search_flights':
        result = await _searchFlights(args);
        break;
      case 'get_flight_details':
        result = await _getFlightDetails(args);
        break;
      case 'book_flight':
        result = await _bookFlight(args);
        break;
      case 'clear_search':
        result = await _clearSearch();
        break;
      case 'get_user_preferences':
        result = await _getUserPreferences();
        break;
      default:
        result = {
          'content': [
            {
              'type': 'text',
              'text': 'Unknown tool: $toolName',
            }
          ],
          'isError': true,
        };
    }
    
    final response = {
      'jsonrpc': '2.0',
      'id': request['id'],
      'result': result,
    };
    
    stdout.writeln(jsonEncode(response));
  } catch (e) {
    final errorResponse = {
      'jsonrpc': '2.0',
      'id': request['id'],
      'result': {
        'content': [
          {
            'type': 'text',
            'text': 'Error: $e',
          }
        ],
        'isError': true,
      },
    };
    
    stdout.writeln(jsonEncode(errorResponse));
  }
}

Future<Map<String, dynamic>> _searchFlights(Map<String, dynamic> args) async {
  try {
    final origin = args['origin'] as String;
    final destination = args['destination'] as String;
    final date = args['date'] as String?;
    final maxPrice = args['max_price']?.toDouble();
    final airline = args['airline'] as String?;

    final flights = MockFlights.searchFlights(
      origin: origin,
      destination: destination,
      date: date,
      maxPrice: maxPrice,
      airline: airline,
    );

    final flightJsonList = flights.map((f) => f.toJson()).toList();
    
    await FileWriter.writeSearchResults(flightJsonList, {
      'origin': origin,
      'destination': destination,
      'date': date,
      'max_price': maxPrice,
      'airline': airline,
    });

    return {
      'content': [
        {
          'type': 'text',
          'text': 'Found ${flights.length} flights from $origin to $destination',
        }
      ],
    };
  } catch (e) {
    stderr.writeln('Error in search_flights: $e');
    return {
      'content': [
        {
          'type': 'text',
          'text': 'Error searching flights: $e',
        }
      ],
      'isError': true,
    };
  }
}

Future<Map<String, dynamic>> _getFlightDetails(Map<String, dynamic> args) async {
  try {
    final flightId = args['flight_id'] as String;
    final flight = MockFlights.getFlightById(flightId);
    
    if (flight == null) {
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Flight not found: $flightId',
          }
        ],
        'isError': true,
      };
    }

    final details = '''Flight Details:
ID: ${flight.id}
Airline: ${flight.airline}
Flight Number: ${flight.flightNumber}
Route: ${flight.origin} (${flight.originCode}) → ${flight.destination} (${flight.destinationCode})
Departure: ${flight.departureTime.toString().substring(0, 16)}
Arrival: ${flight.arrivalTime.toString().substring(0, 16)}
Duration: ${flight.duration}
Price: \$${flight.price} ${flight.currency}
Available Seats: ${flight.seats}
Class: ${flight.flightClass}''';

    return {
      'content': [
        {
          'type': 'text',
          'text': details,
        }
      ],
    };
  } catch (e) {
    stderr.writeln('Error in get_flight_details: $e');
    return {
      'content': [
        {
          'type': 'text',
          'text': 'Error getting flight details: $e',
        }
      ],
      'isError': true,
    };
  }
}

Future<Map<String, dynamic>> _bookFlight(Map<String, dynamic> args) async {
  try {
    final flightId = args['flight_id'] as String;
    final passengerName = args['passenger_name'] as String;
    final email = args['email'] as String?;

    final flight = MockFlights.getFlightById(flightId);
    
    if (flight == null) {
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Flight not found: $flightId',
          }
        ],
        'isError': true,
      };
    }

    if (flight.seats <= 0) {
      return {
        'content': [
          {
            'type': 'text',
            'text': 'No seats available on flight $flightId',
          }
        ],
        'isError': true,
      };
    }

    final success = MockFlights.bookFlight(flightId);
    
    if (!success) {
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Failed to book flight $flightId',
          }
        ],
        'isError': true,
      };
    }

    final confirmationCode = _generateConfirmationCode();
    
    await FileWriter.writeBookingConfirmation(
      confirmationCode: confirmationCode,
      flight: flight.toJson(),
      passenger: {
        'name': passengerName,
        'email': email,
      },
    );

    return {
      'content': [
        {
          'type': 'text',
          'text': 'Booking confirmed! Confirmation code: $confirmationCode for passenger $passengerName on flight ${flight.flightNumber}',
        }
      ],
    };
  } catch (e) {
    stderr.writeln('Error in book_flight: $e');
    return {
      'content': [
        {
          'type': 'text',
          'text': 'Error booking flight: $e',
        }
      ],
      'isError': true,
    };
  }
}

Future<Map<String, dynamic>> _clearSearch() async {
  try {
    await FileWriter.clearData();
    
    return {
      'content': [
        {
          'type': 'text',
          'text': 'Search cleared',
        }
      ],
    };
  } catch (e) {
    stderr.writeln('Error in clear_search: $e');
    return {
      'content': [
        {
          'type': 'text',
          'text': 'Error clearing search: $e',
        }
      ],
      'isError': true,
    };
  }
}

Future<Map<String, dynamic>> _getUserPreferences() async {
  try {
    final prefs = MockFlights.getUserPreferences();
    
    final prefsText = '''User Preferences:
Preferred Airlines: ${(prefs['preferredAirlines'] as List).join(', ')}
Preferred Class: ${prefs['preferredClass']}
Max Budget: \$${prefs['maxBudget']}
Seat Preference: ${prefs['seatPreference']}''';

    return {
      'content': [
        {
          'type': 'text',
          'text': prefsText,
        }
      ],
    };
  } catch (e) {
    stderr.writeln('Error in get_user_preferences: $e');
    return {
      'content': [
        {
          'type': 'text',
          'text': 'Error getting user preferences: $e',
        }
      ],
      'isError': true,
    };
  }
}

String _generateConfirmationCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
}