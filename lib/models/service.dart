import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire3/geoflutterfire3.dart';

class ServiceModel {
  String? id;
  String? title;
  String? description;
  String? imageUrl;
  GeoPoint? location;
  double? price;
  String? phone;
  String? email;
  double? rating;
  String? userId;

  ServiceModel({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.location,
    this.price,
    this.phone,
    this.email,
    this.rating = 0.0,
    this.userId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle location data which might be a GeoPoint or a GeoFirePoint data structure
    GeoPoint? geoPoint;
    if (json['location'] is GeoPoint) {
      geoPoint = json['location'];
    } else if (json['location'] is Map) {
      // Extract GeoPoint from GeoFirePoint data structure
      try {
        final geoData = json['location'] as Map<String, dynamic>;
        if (geoData.containsKey('geopoint')) {
          final geoPointData = geoData['geopoint'] as GeoPoint;
          geoPoint = geoPointData;
        }
      } catch (e) {
        print('Error parsing location data: $e');
      }
    }

    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      location: geoPoint,
      price: (json['price'] as num?)?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'phone': phone,
      'email': email,
      'rating': rating,
      'userId': userId,
    };

    // If id is not null and not empty, include it
    if (id != null && id!.isNotEmpty) {
      data['id'] = id;
    }

    // Convert GeoPoint to GeoFirePoint format if location exists
    if (location != null) {
      // Create a geoFirePoint
      GeoFirePoint geoPoint = GeoFlutterFire().point(
        latitude: location!.latitude,
        longitude: location!.longitude,
      );

      // This stores both the GeoPoint and the geohash in the location field
      data['location'] = geoPoint.data;
    }

    return data;
  }
}
