import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceReport {
  final String id;
  final String code;
  final String title;
  final String description;
  final String category;
  final String location;
  final String classroom;
  final String priority;
  final String status;
  final String imageUrl;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceReport({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.classroom,
    required this.priority,
    required this.status,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceReport.fromMap(Map<String, dynamic> data) {
    return MaintenanceReport(
      id: data['id'] as String,
      code: data['code'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      location: data['location'] as String,
      classroom: data['classroom'] as String,
      priority: data['priority'] as String,
      status: data['status'] as String,
      imageUrl: data['imageUrl'] as String,
      userId: data['userId'] as String,
      createdAt: _fromTimestamp(data['createdAt']),
      updatedAt: _fromTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'classroom': classroom,
      'priority': priority,
      'status': status,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MaintenanceReport copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? category,
    String? location,
    String? classroom,
    String? priority,
    String? status,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceReport(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      classroom: classroom ?? this.classroom,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _fromTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
