import 'package:bloc/bloc.dart';

abstract class HomeStates extends Cubit{}

class InitialStates extends HomeStates{}

class LoadingState extends HomeStates{}

class SuccessState extends HomeStates{}

class ErrorSTate extends HomeStates{}


