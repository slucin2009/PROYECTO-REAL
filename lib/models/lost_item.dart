import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _fromTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}

class LostItem {
  final String id;
  final String title;
  final String userId; // authority who published
  final String status; // 'Pendiente' or 'Entregado'
  final String? withdrawnBy; // name of student who withdrew it
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VerificationQuestion> verificationQuestions;

  LostItem({
    required this.id,
    required this.title,
    required this.userId,
    this.status = 'Pendiente',
    this.withdrawnBy,
    required this.createdAt,
    required this.updatedAt,
    this.verificationQuestions = const [],
  });

  factory LostItem.fromMap(Map<String, dynamic> data) {
    return LostItem(
      id: data['id'] as String,
      title: data['title'] as String,
      userId: data['userId'] as String,
      status: data['status'] as String? ?? 'Pendiente',
      withdrawnBy: data['withdrawnBy'] as String?,
      createdAt: _fromTimestamp(data['createdAt']),
      updatedAt: _fromTimestamp(data['updatedAt']),
      verificationQuestions: (data['verificationQuestions'] as List<dynamic>?)
              ?.map((e) => VerificationQuestion.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'status': status,
      'withdrawnBy': withdrawnBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'verificationQuestions': verificationQuestions.map((q) => q.toMap()).toList(),
    };
  }

  LostItem copyWith({
    String? id,
    String? title,
    String? userId,
    String? status,
    String? withdrawnBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<VerificationQuestion>? verificationQuestions,
  }) {
    return LostItem(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      withdrawnBy: withdrawnBy ?? this.withdrawnBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verificationQuestions: verificationQuestions ?? this.verificationQuestions,
    );
  }

}

class VerificationQuestion {
  final String id;
  final String question;
  final String answer; // correct answer (stored, not shown to claimant)

  VerificationQuestion({required this.id, required this.question, required this.answer});

  factory VerificationQuestion.fromMap(Map<String, dynamic> map) {
    return VerificationQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'question': question, 'answer': answer};
  }
}
