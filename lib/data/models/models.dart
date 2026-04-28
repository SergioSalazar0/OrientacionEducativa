class User {
  final int? id;
  final String email;
  final String role;
  final String name;
  final String phone;
  final String address;

  User({
    this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      role: map['role'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}

class Student {
  final int? id;
  final String name;
  final String grade;
  final String status;
  final int? orientadorId;

  Student({
    this.id,
    required this.name,
    required this.grade,
    required this.status,
    this.orientadorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'status': status,
      'orientador_id': orientadorId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      grade: map['grade'],
      status: map['status'],
      orientadorId: map['orientador_id'],
    );
  }
}

class Report {
  final int? id;
  final int? studentId;
  final int? orientadorId;
  final String title;
  final String description;
  final String followUp;
  final DateTime createdAt;

  Report({
    this.id,
    this.studentId,
    this.orientadorId,
    required this.title,
    required this.description,
    required this.followUp,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'orientador_id': orientadorId,
      'title': title,
      'description': description,
      'follow_up': followUp,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      studentId: map['student_id'],
      orientadorId: map['orientador_id'],
      title: map['title'],
      description: map['description'],
      followUp: map['follow_up'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Justification {
  final int? id;
  final int? studentId;
  final int? orientadorId;
  final String title;
  final String reason;
  final DateTime dateIssued;
  final DateTime createdAt;

  Justification({
    this.id,
    this.studentId,
    this.orientadorId,
    required this.title,
    required this.reason,
    required this.dateIssued,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'orientador_id': orientadorId,
      'title': title,
      'reason': reason,
      'date_issued': dateIssued.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Justification.fromMap(Map<String, dynamic> map) {
    return Justification(
      id: map['id'],
      studentId: map['student_id'],
      orientadorId: map['orientador_id'],
      title: map['title'],
      reason: map['reason'],
      dateIssued: DateTime.parse(map['date_issued']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Announcement {
  final int? id;
  final String title;
  final String description;
  final String targetRole;
  final DateTime createdAt;

  Announcement({
    this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_role': targetRole,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetRole: map['target_role'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Appointment {
  final int? id;
  final int? studentId;
  final int? orientadorId;
  final String title;
  final String description;
  final DateTime appointmentDate;
  final String status; // 'programada', 'completada', 'cancelada'
  final DateTime createdAt;

  Appointment({
    this.id,
    this.studentId,
    this.orientadorId,
    required this.title,
    required this.description,
    required this.appointmentDate,
    this.status = 'programada',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'orientador_id': orientadorId,
      'title': title,
      'description': description,
      'appointment_date': appointmentDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      studentId: map['student_id'],
      orientadorId: map['orientador_id'],
      title: map['title'],
      description: map['description'],
      appointmentDate: DateTime.parse(map['appointment_date']),
      status: map['status'] ?? 'programada',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class AuditLog {
  final int? id;
  final int? userId;
  final String action;
  final String entityType; // 'user', 'student', 'report', 'justification', 'announcement', 'appointment'
  final int? entityId;
  final String details;
  final DateTime createdAt;

  AuditLog({
    this.id,
    this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.details,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'],
      userId: map['user_id'],
      action: map['action'],
      entityType: map['entity_type'],
      entityId: map['entity_id'],
      details: map['details'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
