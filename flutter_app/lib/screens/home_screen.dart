import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../services/data_watcher.dart';
import '../widgets/flight_card.dart';
import '../widgets/booking_confirmation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final DataWatcher _dataWatcher = DataWatcher();
  List<Flight> _flights = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupDataWatcher();
  }

  void _setupDataWatcher() {
    _dataWatcher.flightsStream.listen((flights) {
      if (!mounted) return;
      setState(() {
        _flights = flights;
        _isLoading = false;
      });
    });

    _dataWatcher.bookingStream.listen((booking) {
      if (booking != null) {
        if (!mounted) return;
        showBookingConfirmation(context, booking);
      }
    });

    _dataWatcher.startWatching();
  }

  @override
  void dispose() {
    _dataWatcher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.flight_takeoff, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Travel Assistant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[700],
            child: Row(
              children: [
                if (_isLoading) ...const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Gemini is searching...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ] else if (_flights.isEmpty) ...const [
                  Icon(Icons.chat_bubble_outline,
                      color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Ask Gemini to find flights',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ] else ...[
                  Icon(Icons.check_circle, color: Colors.green[300], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${_flights.length} flights found',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Flight results
          Expanded(
            child: _flights.isEmpty ? _buildEmptyState() : _buildFlightsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flight_takeoff,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready for your next adventure?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ask Gemini to find flights between any two cities',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Text(
                  'Try asking:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"Find flights from San Francisco to Tokyo under \$1000"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _flights.length,
      itemBuilder: (context, index) {
        final flight = _flights[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: FlightCard(
            flight: flight,
            onTap: () => _showFlightDetails(flight),
          ),
        );
      },
    );
  }

  void _showFlightDetails(Flight flight) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flight_takeoff, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Flight Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Flight Number', flight.flightNumber),
            _buildDetailRow('Airline', flight.airline),
            _buildDetailRow('Route',
                '${flight.origin} (${flight.originCode}) → ${flight.destination} (${flight.destinationCode})'),
            _buildDetailRow('Departure', _formatDateTime(flight.departureTime)),
            _buildDetailRow('Arrival', _formatDateTime(flight.arrivalTime)),
            _buildDetailRow('Duration', flight.duration),
            _buildDetailRow('Price', '\$${flight.price.toStringAsFixed(0)}'),
            _buildDetailRow('Available Seats', '${flight.seats}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute';
  }
}
