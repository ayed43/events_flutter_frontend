import 'package:bloc/bloc.dart';
import 'package:demo/api_models/booking/booking_model.dart';
import 'package:demo/constants.dart';
import 'package:demo/cubits/booking_cubit/booking_states.dart';
import 'package:demo/cubits/events_cubit/events_states.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCubit extends Cubit<BookingStates>{
  BookingCubit() : super(InitialBookingState());


  static BookingCubit get(context) => BlocProvider.of(context);



  Booking booking = Booking();

  void bookEvent(int eventId) {
    emit(BookingLoadingState());

    final cache = CacheController();
    final token = cache.token;

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
      HomeCubit()..getData();

    }).catchError((error) {
      emit(BookingErrorState());
      print('Booking Error: $error');
    });
  }



}