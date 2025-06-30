import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:demo/api_models/events_model.dart';
import 'package:demo/cubits/booking_cubit/booking_cubit.dart';
import 'package:demo/cubits/booking_cubit/booking_states.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/pages/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants.dart';
class DetailsPage extends StatelessWidget {
  final EventModel event;

  const DetailsPage(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => BookingCubit(),
    child: BlocConsumer<BookingCubit,BookingStates>(builder: (context, state) {
      return Scaffold(

        backgroundColor: Colors.grey[50],
        body: CustomScrollView(

          slivers: [
            // Hero Image with App Bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.indigo,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Event Image
                    Image.network(
                      '$serverUrl/storage/${event.image}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.indigo[100],
                          child: Icon(
                            Icons.event,
                            size: 80,
                            color: Colors.indigo[300],
                          ),
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Event status badge
                    Positioned(
                      top: 100,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.booked ? Colors.green : Colors.indigo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.booked ? 'BOOKED' : 'AVAILABLE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Event Details Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.indigo[600], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          event.cityName,
                          style: TextStyle(
                            fontSize: 16,

                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Event Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.calendar_today,
                            title: 'Start Date',
                            value: _formatDateTime(event.startTime),
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.schedule,
                            title: 'End Date',
                            value: _formatDateTime(event.endTime),
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.people,
                            title: 'Capacity',
                            value: '${event.capacity} people',
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.event_seat,
                            title: 'Available',
                            value: '${event.availableSeats} seats',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.indigo[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'About This Event',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Map Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.indigo[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Event Location',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Map Preview
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 200,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(event.latitude, event.longitude),
                                    zoom: 15,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId('event_location'),
                                      position: LatLng(event.latitude, event.longitude),
                                    )
                                  },
                                  zoomControlsEnabled: true,
                                  liteModeEnabled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Booking Button

        floatingActionButton: event.booked
            ? null // ✅ No button shown if already booked
            : Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: FloatingActionButton.extended(
            onPressed: () {
              BookingCubit.get(context).bookEvent(event.id);
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
               return App();
             },));

            },
            backgroundColor: Colors.indigo,
            elevation: 8,
            icon: const Icon(Icons.book_online, color: Colors.white),
            label: Text(
              event.availableSeats > 0 ? 'Book Now' : 'Sold Out',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),


        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );

    }, listener: (context, state) {
       if (state is BookingSuccessState){
         final snackBar = SnackBar(
           elevation: 0,
           behavior: SnackBarBehavior.floating,
           backgroundColor: Colors.transparent,
           margin: const EdgeInsets.fromLTRB(16, 50, 16, 0), // تحركه للأعلى (50 من الأعلى)
           content: AwesomeSnackbarContent(
             title: 'Congrats!',
             message:  'Booking done successfully',
             contentType: ContentType.success,
           ),
           duration: const Duration(seconds: 3),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
         );
         ScaffoldMessenger.of(context)
           ..hideCurrentSnackBar()
           ..showSnackBar(snackBar);

       }
    },),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy\nHH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}