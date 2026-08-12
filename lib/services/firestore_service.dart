import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_fix/models/lost_item.dart';
import 'package:campus_fix/models/maintenance_report.dart';
import 'package:campus_fix/models/claim.dart';
import 'package:campus_fix/models/app_user.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> createLostItem(LostItem item) async {
    final id = _uuid.v4();
    await _db.collection('lost_items').doc(id).set(item.copyWith(id: id, createdAt: DateTime.now(), updatedAt: DateTime.now()).toMap());
  }

  Future<void> createMaintenanceReport(MaintenanceReport report) async {
    final id = _uuid.v4();
    final toSave = report.copyWith(id: id, createdAt: DateTime.now(), updatedAt: DateTime.now());
    // Ensure userId is not empty; if empty, store as provided (studentSessionId should be passed)
    await _db.collection('maintenance_reports').doc(id).set(toSave.toMap());
  }

  Future<List<LostItem>> fetchLostItems() async {
    final query = await _db.collection('lost_items').orderBy('createdAt', descending: true).get();
    return query.docs.map((doc) => LostItem.fromMap(doc.data())).toList();
  }

  Future<LostItem?> fetchLostItemById(String id) async {
    final snapshot = await _db.collection('lost_items').doc(id).get();
    if (!snapshot.exists) return null;
    return LostItem.fromMap(snapshot.data()!);
  }

  Future<void> updateLostItem(LostItem item) async {
    await _db.collection('lost_items').doc(item.id).set(item.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteLostItem(String id) async {
    await _db.collection('lost_items').doc(id).delete();
  }

  Future<List<Claim>> fetchClaims({String? userId, bool onlyMine = false}) async {
    final collection = _db.collection('claims');
    final query = onlyMine && userId != null
        ? collection.where('userId', isEqualTo: userId)
        : collection;
    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // ensure id exists in map
      data['id'] = data['id'] ?? doc.id;
      return Claim.fromMap(Map<String, dynamic>.from(data));
    }).toList();
  }

  Future<Claim?> fetchClaimById(String id) async {
    final snapshot = await _db.collection('claims').doc(id).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data()!;
    data['id'] = data['id'] ?? snapshot.id;
    return Claim.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> updateClaim(Claim claim) async {
    await _db.collection('claims').doc(claim.id).set(claim.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> createClaim(Claim claim) async {
    final id = _uuid.v4();
    final toSave = claim.copyWith(id: id, createdAt: DateTime.now(), updatedAt: DateTime.now());
    await _db.collection('claims').doc(id).set(toSave.toMap());
  }

  Future<void> deleteClaim(String id) async {
    await _db.collection('claims').doc(id).delete();
  }

  Future<List<MaintenanceReport>> fetchMaintenanceReports(String userId, {bool onlyMine = false}) async {
    final collection = _db.collection('maintenance_reports');
    final query = onlyMine ? collection.where('userId', isEqualTo: userId) : collection;
    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => MaintenanceReport.fromMap(doc.data())).toList();
  }

  Future<MaintenanceReport?> fetchMaintenanceReportById(String id) async {
    final snapshot = await _db.collection('maintenance_reports').doc(id).get();
    if (!snapshot.exists) return null;
    return MaintenanceReport.fromMap(snapshot.data()!);
  }

  Future<void> updateMaintenanceReport(MaintenanceReport report) async {
    await _db.collection('maintenance_reports').doc(report.id).set(report.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteMaintenanceReport(String id) async {
    await _db.collection('maintenance_reports').doc(id).delete();
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    if (!snapshot.exists) return null;
    return AppUser.fromMap(snapshot.data()!..putIfAbsent('id', () => uid));
  }

  /// Obtiene el nombre de un usuario por su ID. Retorna el nombre o el ID si no existe.
  Future<String> fetchUserNameOrId(String userId) async {
    try {
      final user = await fetchUserProfile(userId);
      return user?.name ?? userId;
    } catch (_) {
      return userId;
    }
  }
}
