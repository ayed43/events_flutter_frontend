abstract class BookingStates{}

class InitialBookingState extends BookingStates{}

class BookingLoadingState extends BookingStates {}

class BookingSuccessState extends BookingStates{}

class BookingErrorState extends BookingStates{}

class BookingCancelSuccessState extends BookingStates{
  final String message;

  BookingCancelSuccessState(this.message);
}