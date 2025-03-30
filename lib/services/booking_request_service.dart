import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_request.dart';

class BookingRequestService {
  final CollectionReference<Map<String, dynamic>> _bookingRequestsCollection =
      FirebaseFirestore.instance.collection('booking_requests');

  Future<List<BookingRequestModel>> getBookingRequestsForUser(
      String userId, String status) async {
    Query<Map<String, dynamic>> query =
        _bookingRequestsCollection.where('userId', isEqualTo: userId);
    if (status != 'all') {
      query = query.where('status', isEqualTo: status);
    }
    final bookingRequestsSnapshot = await query.get();
    return bookingRequestsSnapshot.docs
        .map((doc) => BookingRequestModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<BookingRequestModel>> getAllBookingRequestsForUser(
      String userId) async {
    Query<Map<String, dynamic>> query =
        _bookingRequestsCollection.where('userId', isEqualTo: userId);

    final bookingRequestsSnapshot = await query.get();
    return bookingRequestsSnapshot.docs
        .map((doc) => BookingRequestModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<BookingRequestModel>> getBookingRequestsForProvider(
      String providerId, String status) async {
    Query<Map<String, dynamic>> query =
        _bookingRequestsCollection.where('providerId', isEqualTo: providerId);
    if (status != 'all') {
      query = query.where('status', isEqualTo: status);
    }
    final bookingRequestsSnapshot = await query.get();
    return bookingRequestsSnapshot.docs
        .map((doc) => BookingRequestModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<BookingRequestModel>> getAllBookingRequestsForProvider(
      String providerId) async {
    Query<Map<String, dynamic>> query =
        _bookingRequestsCollection.where('providerId', isEqualTo: providerId);

    final bookingRequestsSnapshot = await query.get();
    return bookingRequestsSnapshot.docs
        .map((doc) => BookingRequestModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateBookingRequestStatus(
      String bookingRequestId, String status,
      {double? userRating}) async {
    Map<String, dynamic> updateData = {'status': status};
    if (userRating != null) {
      updateData['userRating'] = userRating;
    }
    await _bookingRequestsCollection.doc(bookingRequestId).update(updateData);
  }
}
