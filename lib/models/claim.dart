import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _fromTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}

class Claim {
  final String id;
  final String lostItemId;
  final String userId; // student who claims
  final String status; // 'Pendiente', 'Aprobada', 'Rechazada'
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VerificationAnswer> verificationAnswers;

  Claim({
    required this.id,
    required this.lostItemId,
    required this.userId,
    this.status = 'Pendiente',
    required this.createdAt,
    required this.updatedAt,
    this.verificationAnswers = const [],
  });

  factory Claim.fromMap(Map<String, dynamic> data) {
    return Claim(
      id: data['id'] as String,
      lostItemId: data['lostItemId'] as String,
      userId: data['userId'] as String,
      status: data['status'] as String? ?? 'Pendiente',
      createdAt: _fromTimestamp(data['createdAt']),
      updatedAt: _fromTimestamp(data['updatedAt']),
      verificationAnswers: (data['verificationAnswers'] as List<dynamic>?)
              ?.map((e) => VerificationAnswer.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lostItemId': lostItemId,
      'userId': userId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'verificationAnswers': verificationAnswers.map((a) => a.toMap()).toList(),
    };
  }

  Claim copyWith({
    String? id,
    String? lostItemId,
    String? userId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<VerificationAnswer>? verificationAnswers,
  }) {
    return Claim(
      id: id ?? this.id,
      lostItemId: lostItemId ?? this.lostItemId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verificationAnswers: verificationAnswers ?? this.verificationAnswers,
    );
  }

}

class VerificationAnswer {
  final String questionId;
  final String answer;

  VerificationAnswer({required this.questionId, required this.answer});

  factory VerificationAnswer.fromMap(Map<String, dynamic> map) {
    return VerificationAnswer(
      questionId: map['questionId'] as String,
      answer: map['answer'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'questionId': questionId, 'answer': answer};
  }
}

