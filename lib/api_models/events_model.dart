  class EventModel {
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
    final bool isActive;
    final String createdAt;
    final String updatedAt;
    final int capacity;
    final int availableSeats;
    final bool booked;
    final String cityName;

    EventModel({
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
      required this.booked,
      required this.cityName
    });

    factory EventModel.fromJson(Map<String, dynamic> json) {
      return EventModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        cityId: json['city_id'],
        categoryId: json['category_id'],

        image: json['image'],
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
        isActive: json['is_active'] == 1,
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        capacity: json['capacity'],
        availableSeats: json['available_seats'],
        booked: json['booked'],
        cityName: json['city_name'],
      );
    }
  }
