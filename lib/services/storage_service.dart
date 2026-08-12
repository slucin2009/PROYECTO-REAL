import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  final _storage = FirebaseStorage.instance;

  Future<String> uploadLostItemPhoto(String itemId, File file) async {
    final ref = _storage.ref('lost_items/$itemId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadReportPhoto(String reportId, File file) async {
    final ref = _storage.ref('reports/$reportId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
