
import 'package:bloc/bloc.dart';
import 'package:demo/cubits/events_cubit/events_states.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventCubit extends Cubit<EventsStates>{
  EventCubit(super.InitialEventState);
  static EventCubit get(context) => BlocProvider.of(context);



}