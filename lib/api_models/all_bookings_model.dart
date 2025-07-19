class AllBookingResponse {
  final bool status;
  final List<BookingResponse> bookings;

  AllBookingResponse({
    required this.status,
    required this.bookings,
  });

  factory AllBookingResponse.fromJson(Map<String, dynamic> json) {
    return AllBookingResponse(
      status: json['status'] ?? false,
      bookings: (json['bookings'] as List<dynamic>?)
          ?.map((booking) => BookingResponse.fromJson(booking))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'bookings': bookings.map((booking) => booking.toJson()).toList(),
    };
  }
}

class BookingResponse {
  final int id;
  final int userId;
  final int eventId;
  final String status;
  final String bookingDate;
  final String createdAt;
  final String updatedAt;
  final EventResponse event;

  BookingResponse({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.bookingDate,
    required this.createdAt,
    required this.updatedAt,
    required this.event,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      status: json['status'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      event: EventResponse.fromJson(json['event'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'status': status,
      'booking_date': bookingDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'event': event.toJson(),
    };
  }
}

class EventResponse {
  final int id;
  final String name;
  final String description;
  final String startTime;
  final String endTime;
  final int cityId;
  final int categoryId;
  final String image;
  final double latitude;
  final double longitude;
  final bool isActive;  // Changed from int to bool
  final String createdAt;
  final String updatedAt;
  final int capacity;
  final int availableSeats;
  final int providerId;  // Added missing field from API

  EventResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.cityId,
    required this.categoryId,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.capacity,
    required this.availableSeats,
    required this.providerId,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      cityId: json['city_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      image: json['image'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      isActive: json['is_active'] ?? false,  // Changed to handle bool
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      capacity: json['capacity'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      providerId: json['provider_id'] ?? 0,  // Added missing field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'city_id': cityId,
      'category_id': categoryId,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'capacity': capacity,
      'available_seats': availableSeats,
      'provider_id': providerId,
    };
  }
}