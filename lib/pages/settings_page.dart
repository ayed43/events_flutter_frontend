import 'package:demo/constants.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/pages/details_page/details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      builder: (context, state) {
        final events = HomeCubit.get(context).events;

        if (events.isEmpty) {
          return const Center(child: Text('No events available'));
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final imageUrl = '$serverUrl/storage/${event.image}';
            final date = DateFormat.yMMMMd().add_jm().format(DateTime.parse(event.startTime));

            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DetailsPage(event);
                },));
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    ),
                    // Event Info
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            event.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          // Date and location
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(date, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('City ID: ${event.cityName}', style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.event_seat, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${event.availableSeats} / ${event.capacity} seats available',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Booking status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Chip(
                                label: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(Icons.file_download_outlined,color: Colors.white,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(event.booked ? 'Booked' : 'book now'),
                                    ),
                                  ],
                                ),
                                backgroundColor: event.booked ? Colors.red.shade100 : Colors.indigo.shade400,
                                labelStyle: TextStyle(
                                  color: event.booked ? Colors.red : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      listener: (context, state) {},
    );
  }
}
