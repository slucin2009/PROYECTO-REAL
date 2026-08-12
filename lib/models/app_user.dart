import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      role: _roleFromString(data['role'] as String? ?? 'student'),
      createdAt: _fromTimestamp(data['createdAt']),
      updatedAt: _fromTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': _roleToString(role),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'teacher';
      case UserRole.admin:
        return 'admin';
      default:
        return 'student';
    }
  }

  static DateTime _fromTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
