import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahel_alik/models/service.dart';
import 'package:geoflutterfire3/geoflutterfire3.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ServiceService {
  final CollectionReference _serviceCollection =
      FirebaseFirestore.instance.collection('services');
  final GeoFlutterFire _geo = GeoFlutterFire();

  // Get services by category and location
  Stream<List<ServiceModel>> getServicesByCategoryAndLocation({
    required String category,
    required double latitude,
    required double longitude,
    required double radius,
  }) {
    GeoFirePoint center = _geo.point(latitude: latitude, longitude: longitude);

    return _geo
        .collection(
            collectionRef:
                _serviceCollection.where('category', isEqualTo: category))
        .within(
          center: center,
          radius: radius,
          field: 'location',
          strictMode: true,
        )
        .map((List<DocumentSnapshot<Object?>> documentList) {
      return documentList.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceModel.fromJson(data);
      }).toList();
    });
  }

  // Get nearest services regardless of category
  Stream<List<ServiceModel>> getNearestServices({
    required double latitude,
    required double longitude,
    required double radius,
  }) {
    GeoFirePoint center = _geo.point(latitude: latitude, longitude: longitude);

    return _geo
        .collection(collectionRef: _serviceCollection)
        .within(
          center: center,
          radius: radius,
          field: 'location',
          strictMode: true,
        )
        .map((List<DocumentSnapshot<Object?>> documentList) {
      return documentList.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceModel.fromJson(data);
      }).toList();
    });
  }

  // Add a new service
  Future<ServiceModel?> addService(ServiceModel service) async {
    try {
      // Create a copy of the service with proper location format
      final serviceData = service.toJson();

      DocumentReference docRef = await _serviceCollection.add(serviceData);

      // Update the service with its ID
      await docRef.update({'id': docRef.id});

      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return ServiceModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error adding service: $e');
      return null;
    }
  }

  // Get services for a specific provider (user) and status
  Future<List<ServiceModel>> getServicesForProvider(String status) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return []; // No user logged in
      }

      Query query = _serviceCollection.where('userId', isEqualTo: userId);
      if (status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) =>
              ServiceModel.fromJson(doc.data() as Map<String, dynamic>)
                ..id = doc.id)
          .toList();
    } catch (e) {
      print('Error fetching provider services: $e');
      return [];
    }
  }

  // Get service details by ID
  Future<ServiceModel?> getServiceDetails(String serviceId) async {
    try {
      DocumentSnapshot snapshot = await _serviceCollection.doc(serviceId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id;
        return ServiceModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting service details: $e');
      return null;
    }
  }

  // Get nearby services using GeoFlutterFire
  Stream<List<ServiceModel>> getNearbyServices(GeoPoint center, double radius) {
    // Create a geoFirePoint
    GeoFirePoint geoPoint = _geo.point(
      latitude: center.latitude,
      longitude: center.longitude,
    );

    return _geo
        .collection(collectionRef: _serviceCollection)
        .within(
          center: geoPoint,
          radius: radius, // in kilometers
          field: 'location',
          strictMode: true,
        )
        .map((List<DocumentSnapshot> documents) {
      return documents.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceModel.fromJson(data);
      }).toList();
    });
  }

  // Update an existing service
  Future<ServiceModel?> updateService(
      String serviceId, ServiceModel service) async {
    try {
      // Make sure the ID is set
      service.id = serviceId;

      await _serviceCollection.doc(serviceId).update(service.toJson());

      DocumentSnapshot snapshot = await _serviceCollection.doc(serviceId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id;
        return ServiceModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error updating service: $e');
      return null;
    }
  }

  // Delete a service
  Future<bool> deleteService(String serviceId) async {
    try {
      await _serviceCollection.doc(serviceId).delete();
      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  // Get all services
  Stream<List<ServiceModel>> getAllServices() {
    return _serviceCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceModel.fromJson(data);
      }).toList();
    });
  }

  // Get services by user ID
  Stream<List<ServiceModel>> getUserServices(String userId) {
    return _serviceCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceModel.fromJson(data);
      }).toList();
    });
  }
}
