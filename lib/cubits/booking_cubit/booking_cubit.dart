import 'package:bloc/bloc.dart';
import 'package:demo/cubits/booking_cubit/booking_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCubit extends Cubit<BookingStates>{
  BookingCubit() : super(InitialBookingState());


  static BookingCubit get(context) => BlocProvider.of(context);


}