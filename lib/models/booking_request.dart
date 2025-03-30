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
  double? userRating;
  Timestamp? createdAt;
  double? price; // Add price here

  BookingRequestModel({
    this.bookingRequestId,
    this.userId,
    this.providerId,
    this.serviceId,
    this.dateTime,
    this.description,
    this.status = 'pending',
    this.paymentMethod,
    this.userRating,
    this.createdAt,
    this.price, // Add price in constructor
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
      userRating: (json['userRating'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(), // Add price in fromJson
      createdAt: json['createdAt'],
    );
  }

  factory BookingRequestModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return BookingRequestModel(
      bookingRequestId: data?['bookingRequestId'],
      userId: data?['userId'],
      providerId: data?['providerId'],
      serviceId: data?['serviceId'],
      dateTime: data?['dateTime']?.toDate(),
      description: data?['description'],
      status: data?['status'] ?? 'pending',
      paymentMethod: data?['paymentMethod'],
      userRating: (data?['userRating'] as num?)?.toDouble(),
      price: (data?['price'] as num?)?.toDouble(), // Add price in fromFirestore
      createdAt: data?['createdAt'],
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
      'userRating': userRating,
      'price': price, // Add price in toJson
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }
}
