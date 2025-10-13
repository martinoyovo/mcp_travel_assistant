import 'package:flutter/material.dart';
import '../models/flight.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final BookingConfirmation booking;
  final VoidCallback? onDismiss;

  const BookingConfirmationDialog({
    Key? key,
    required this.booking,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green[600],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Confirmation title
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Confirmation code
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.confirmation_number, 
                       size: 20, 
                       color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    booking.confirmationCode,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Flight details summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flight Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Flight', booking.flight.flightNumber),
                  _buildDetailRow('Route', 
                      '${booking.flight.originCode} → ${booking.flight.destinationCode}'),
                  _buildDetailRow('Date', 
                      _formatDate(booking.flight.departureTime)),
                  _buildDetailRow('Passenger', booking.passengerName),
                  if (booking.email != null)
                    _buildDetailRow('Email', booking.email!),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}

void showBookingConfirmation(BuildContext context, BookingConfirmation booking) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BookingConfirmationDialog(
      booking: booking,
      onDismiss: () {
        // Auto-dismiss after showing
        Future.delayed(Duration(seconds: 3), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      },
    ),
  );
}