import 'package:bloc/bloc.dart';
import 'package:demo/api_models/all_bookings_model.dart';
import 'package:demo/api_models/booking/booking_model.dart';
import 'package:demo/constants.dart';
import 'package:demo/cubits/booking_cubit/booking_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCubit extends Cubit<BookingStates>{
  BookingCubit() : super(InitialBookingState());

  static BookingCubit get(context) => BlocProvider.of(context);



  void bookEvent(int eventId) {
    emit(BookingLoadingState());
    final cache = CacheController();
    final token = cache.token;

    dynamic booking;
    DioHelper.postData(
      url: '${serverUrl}/api/booking',
      data: {'event_id': eventId},
      bearerToken: token,
    ).then((response) {
      // Parse the entire response JSON into Booking model
      booking = Booking.fromJson(response.data);

      // Print the message from response
      print(booking.message); // e.g., "Booking created successfully."
      emit(BookingSuccessState());



    }).catchError((error) {
      emit(BookingErrorState());
      print('Booking Error: $error');
    });
  }

  // Cancel booking functionality
// In your BookingCubit, replace the cancelBooking method with this:

  void cancelBooking(int eventId) {
    emit(BookingLoadingState());

    final cache = CacheController();
    final token = cache.token;

    DioHelper.postData(
      url: '${serverUrl}/api/booking/cancel',
      data: {'event_id': eventId},
      bearerToken: token,
    ).then((response) {
      emit(BookingSuccessState());
      print('Cancel Response: ${response.data}');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['status'] == true) {
          // Remove the canceled booking from the local list
          bookings.removeWhere((booking) => booking.event.id == eventId);

          // Update the response object
          if (allBookingsResponse != null) {
            allBookingsResponse = AllBookingResponse(
              status: allBookingsResponse!.status,
              bookings: bookings,
            );
          }

          print('✅ ${responseData['message']}');

          // SIMPLE FIX: Emit loading first, then success to force rebuild


        } else {
          print('⚠️ Cancel failed: ${responseData['message']}');
          emit(BookingErrorState());
        }
      } else {
        print('⚠️ Invalid cancel response format');
        emit(BookingErrorState());
      }
    }).catchError((error) {
      print('❌ Cancel Error: $error');
      emit(BookingErrorState());
    });
  }

  AllBookingResponse? allBookingsResponse;
  List<BookingResponse> bookings = [];

  getAllBookings() {
    emit(BookingLoadingState());

    final cache = CacheController();
    final token = cache.token;

    DioHelper.getData(
      url: '${serverUrl}/api/booking',
      bearerToken: token,
    ).then((value) {
      // print(value.data);

      if (value.data != null && value.data is Map<String, dynamic>) {
        try {
          // Parse the response using AllBookingResponse
          allBookingsResponse = AllBookingResponse.fromJson(value.data);

          // Store bookings list for easier access
          bookings = allBookingsResponse!.bookings;

          // Check if the API status is successful
          if (allBookingsResponse!.status) {
            // print("✅ تم جلب ${bookings.length} حجز بنجاح");

            // Optional: Print booking details for debugging
            for (var booking in bookings) {
              // print("حجز رقم: ${booking.id} - فعالية: ${booking.event.name}");
            }

            emit(BookingSuccessState());
          } else {
            print("⚠️ API returned status: false");
            emit(BookingErrorState());
          }

        } catch (parseError) {
          print("⚠️ خطأ في تحليل البيانات: $parseError");
          emit(BookingErrorState());
        }
      } else {
        print("⚠️ خطأ: القيمة المستلمة ليست JSON Map.");
        emit(BookingErrorState());
      }
    }).catchError((error) {
      print("❌ API Error: $error");
      emit(BookingErrorState());
    });
  }
}