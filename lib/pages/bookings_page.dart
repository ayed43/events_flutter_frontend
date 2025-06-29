import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:demo/api_models/all_bookings_model.dart';
import 'package:demo/cubits/booking_cubit/booking_cubit.dart';
import 'package:demo/cubits/booking_cubit/booking_states.dart';
import 'package:demo/pages/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCancelSuccessState extends BookingStates {
  final String message;
  BookingCancelSuccessState(this.message);
}

enum BookingFilter { all, active, canceled }

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late BookingCubit _bookingCubit;
  BookingFilter selectedFilter = BookingFilter.all;

  @override
  void initState() {
    super.initState();
    _bookingCubit = BookingCubit();
    _bookingCubit.getAllBookings();
  }

  @override
  void dispose() {
    _bookingCubit.close();
    super.dispose();
  }

  List<BookingResponse> _filteredBookings(List<BookingResponse> allBookings) {
    switch (selectedFilter) {
      case BookingFilter.active:
        return allBookings.where((b) => b.status.toLowerCase() == 'success').toList();
      case BookingFilter.canceled:
        return allBookings.where((b) => b.status.toLowerCase() == 'canceled').toList();
      case BookingFilter.all:
      default:
        return allBookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingCubit>.value(
      value: _bookingCubit,
      child: BlocConsumer<BookingCubit, BookingStates>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          if (state is BookingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingSuccessState) {
            if (_bookingCubit.bookings.isEmpty) {
              return const Center(
                child: Text('No bookings found', style: TextStyle(fontSize: 16, color: Colors.grey)),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: [
                      selectedFilter == BookingFilter.all,
                      selectedFilter == BookingFilter.active,
                      selectedFilter == BookingFilter.canceled,
                    ],
                    onPressed: (index) {
                      setState(() {
                        selectedFilter = BookingFilter.values[index];
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('All'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Active'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Canceled'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _bookingCubit.getAllBookings();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: BookingsList(bookings: _filteredBookings(_bookingCubit.bookings)),
                  ),
                ),
              ],
            );
          } else if (state is BookingErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load bookings'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _bookingCubit.getAllBookings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Initializing...'));
        },
        listenWhen: (previous, current) =>
        current is BookingSuccessState ||
            current is BookingErrorState ||
            current is BookingCancelSuccessState,
        listener: (context, state) {
          if (state is BookingCancelSuccessState) {
            // optionally show something
          } else if (state is BookingErrorState) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Failed to process request'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}

class BookingsList extends StatelessWidget {
  final List<BookingResponse> bookings;

  const BookingsList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              booking.event.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking ID: ${booking.id}'),
                Text('Status: ${booking.status.toUpperCase()}'),
                Text('Date: ${_formatDate(booking.bookingDate)}'),
              ],
            ),
            trailing: booking.status.toLowerCase() == 'success'
                ? ElevatedButton(
              onPressed: () {
                _showCancelDialog(context, booking.event.id, booking.event.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Cancel'),
            )
                : Chip(
              label: Text(
                booking.status.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getStatusColor(booking.status),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, int eventId, String eventName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel your booking for "$eventName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<BookingCubit>(context).cancelBooking(eventId);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => App()));
                final snackBar = SnackBar(
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  margin: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                  content: AwesomeSnackbarContent(
                    title: 'Success!',
                    message: 'Booking canceled. You can rejoin anytime!',
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green[100]!;
      case 'pending':
        return Colors.orange[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
