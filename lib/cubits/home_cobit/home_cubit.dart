import 'package:demo/api_models/events_model.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../api_models/category_model.dart';
import '../../models/cache_controller/cache_controller.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(InitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  List<CategoryModel> categories = [];
  List<EventModel> events = [];
  List<EventModel> nearbyEvents = [];

  getData() {
    final cache = CacheController();
    final token = cache.token;
    emit(LoadingState());
    DioHelper.getData(
        url: '/api/home',
        headers: {'Authorization': 'Bearer ${token}'}
    ).then((value) {
      emit(SuccessState());
      List categoriesData = value.data['categories'];
      categories = categoriesData.map((e) => CategoryModel.fromJson(e)).toList();
      List eventData = value.data['events'];
      events = eventData.map((e) => EventModel.fromJson(e)).toList();

      // Calculate nearby events after getting all events
      _calculateNearbyEvents(cache);

    }).catchError((error) {
      emit(ErrorSTate());
      print(error.toString());
    });
  }

  void _calculateNearbyEvents(CacheController cache, {double radiusKm = 50.0}) {
    nearbyEvents.clear();

    // Check if user location is available
    if (!cache.hasLocationData) {
      print('No user location available for nearby events calculation');
      return;
    }

    final userLat = cache.myLat!;
    final userLng = cache.myLang!;

    print('User location: $userLat, $userLng');
    print('Calculating nearby events within ${radiusKm}km radius');

    for (var event in events) {
      // Check if event has valid coordinates
      if (event.latitude != null && event.longitude != null) {
        double distance = _calculateDistance(
            userLat,
            userLng,
            event.latitude!,
            event.longitude!
        );

        print('Event: ${event.name}, Distance: ${distance.toStringAsFixed(2)}km');

        if (distance <= radiusKm) {
          nearbyEvents.add(event);
        }
      }
    }

    // Sort nearby events by distance (closest first)
    nearbyEvents.sort((a, b) {
      double distanceA = _calculateDistance(userLat, userLng, a.latitude!, a.longitude!);
      double distanceB = _calculateDistance(userLat, userLng, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });

    print('Found ${nearbyEvents.length} nearby events');
    emit(SuccessState());
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get distance for a specific event from user location
  double? getEventDistance(EventModel event) {
    final cache = CacheController();
    if (!cache.hasLocationData || event.latitude == null || event.longitude == null) {
      return null;
    }

    return _calculateDistance(
        cache.myLat!,
        cache.myLang!,
        event.latitude!,
        event.longitude!
    );
  }

  // Manually refresh nearby events with custom radius
  void refreshNearbyEvents({double radiusKm = 50.0}) {
    final cache = CacheController();
    _calculateNearbyEvents(cache, radiusKm: radiusKm);
  }
}