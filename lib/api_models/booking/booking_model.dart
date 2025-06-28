import 'package:demo/api_models/events_model.dart';

class Booking {
  String? message;
  int? userId;
  String? eventId;
  String? status;
  String? updatedAt;
  String? createdAt;
  int? id;
  EventModel ?event;

  Booking({
    this.message,
    this.userId,
    this.eventId,
    this.status,
    this.updatedAt,
    this.createdAt,
    this.id

  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      message: json['message'],
      userId: json['booking']?['user_id'],
      eventId: json['booking']?['event_id']?.toString(),
      status: json['booking']?['status'],
      updatedAt: json['booking']?['updated_at'],
      createdAt: json['booking']?['created_at'],
      id: json['booking']?['id']

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'booking': {
        'user_id': userId,
        'event_id': eventId,
        'status': status,
        'updated_at': updatedAt,
        'created_at': createdAt,
        'id': id,
      },
    };
  }
}
