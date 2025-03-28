import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequestModel {
  String? bookingRequestId;
  String? userId;
  String? providerId;
  String? serviceId;
  DateTime? dateTime;
  String? description;
  String? status;
  String? paymentMethod;
  double? userRating; // Added userRating field
  Timestamp? createdAt;

  BookingRequestModel({
    this.bookingRequestId,
    this.userId,
    this.providerId,
    this.serviceId,
    this.dateTime,
    this.description,
    this.status = 'pending',
    this.paymentMethod,
    this.userRating, // Include userRating in constructor
    this.createdAt,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      bookingRequestId: json['bookingRequestId'],
      userId: json['userId'],
      providerId: json['providerId'],
      serviceId: json['serviceId'],
      dateTime: json['dateTime']?.toDate(),
      description: json['description'],
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      userRating: (json['userRating'] as num?)
          ?.toDouble(), // Parse userRating from json
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingRequestId': bookingRequestId,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'dateTime': dateTime,
      'description': description,
      'status': status,
      'paymentMethod': paymentMethod,
      'userRating': userRating, // Added userRating to toJson
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }
}
