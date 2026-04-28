import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_service.dart';
import '../data/models/models.dart';

// Provider para la sesión del usuario
final sessionProvider = StateNotifierProvider<SessionNotifier, User?>((ref) {
  return SessionNotifier();
});

class SessionNotifier extends StateNotifier<User?> {
  SessionNotifier() : super(null);

  void login(User user) {
    state = user;
  }

  void logout() {
    state = null;
  }

  Future<void> updateProfile(String name, String phone, String address) async {
    if (state != null) {
      final updatedUser = User(
        id: state!.id,
        email: state!.email,
        role: state!.role,
        name: name,
        phone: phone,
        address: address,
      );
      state = updatedUser;

      if (updatedUser.id != null) {
        final data = Map<String, dynamic>.from(updatedUser.toMap())..remove('id');
        await SupabaseService.instance.update('users', data, 'id', updatedUser.id);
      }
    }
  }
}

// Provider para estudiantes (solo para orientador)
final studentsProvider = FutureProvider<List<Student>>((ref) async {
  try {
    final maps = await SupabaseService.instance.selectAll(
      'students',
      orderBy: 'created_at',
      ascending: false,
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  } catch (e) {
    // Si hay error de RLS o conexión, devolver lista vacía
    return [];
  }
});

// Provider para reportes
final reportsProvider = StateNotifierProvider<ReportsNotifier, List<Report>>((ref) {
  return ReportsNotifier();
});

class ReportsNotifier extends StateNotifier<List<Report>> {
  ReportsNotifier() : super([]) {
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final maps = await SupabaseService.instance.selectAll(
        'reports',
        orderBy: 'created_at',
        ascending: false,
      );
      state = maps.map((map) => Report.fromMap(map)).toList();
    } catch (e) {
      // Ignorar errores iniciales de carga
      state = [];
    }
  }

  Future<void> loadReports() async {
    try {
      final maps = await SupabaseService.instance.selectAll(
        'reports',
        orderBy: 'created_at',
        ascending: false,
      );
      state = maps.map((map) => Report.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addReport(Report report) async {
    final inserted = await SupabaseService.instance.insertReturning('reports', report.toMap());
    final newReport = Report(
      id: inserted['id'] as int?,
      studentId: report.studentId,
      orientadorId: report.orientadorId,
      title: report.title,
      description: report.description,
      followUp: report.followUp,
      createdAt: report.createdAt,
    );
    state = [newReport, ...state];
  }

  Future<void> updateReport(Report report) async {
    final data = Map<String, dynamic>.from(report.toMap())..remove('id');
    await SupabaseService.instance.update('reports', data, 'id', report.id);
    state = state.map((item) => item.id == report.id ? report : item).toList();
  }

  Future<void> deleteReport(int id) async {
    await SupabaseService.instance.delete('reports', 'id', id);
    state = state.where((item) => item.id != id).toList();
  }
}

// Provider para justificantes
final justificationsProvider = StateNotifierProvider<JustificationsNotifier, List<Justification>>((ref) {
  return JustificationsNotifier();
});

class JustificationsNotifier extends StateNotifier<List<Justification>> {
  JustificationsNotifier() : super([]) {
    _loadJustifications();
  }

  Future<void> _loadJustifications() async {
    try {
      final maps = await SupabaseService.instance.selectAll(
        'justifications',
        orderBy: 'created_at',
        ascending: false,
      );
      state = maps.map((map) => Justification.fromMap(map)).toList();
    } catch (e) {
      // Ignorar errores iniciales de carga
      state = [];
    }
  }

  Future<void> loadJustifications() async {
    try {
      final maps = await SupabaseService.instance.selectAll(
        'justifications',
        orderBy: 'created_at',
        ascending: false,
      );
      state = maps.map((map) => Justification.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addJustification(Justification justification) async {
    final inserted = await SupabaseService.instance.insertReturning('justifications', justification.toMap());
    final newJustification = Justification(
      id: inserted['id'] as int?,
      studentId: justification.studentId,
      orientadorId: justification.orientadorId,
      title: justification.title,
      reason: justification.reason,
      dateIssued: justification.dateIssued,
      createdAt: justification.createdAt,
    );
    state = [newJustification, ...state];
  }

  Future<void> updateJustification(Justification justification) async {
    final data = Map<String, dynamic>.from(justification.toMap())..remove('id');
    await SupabaseService.instance.update('justifications', data, 'id', justification.id);
    state = state.map((item) => item.id == justification.id ? justification : item).toList();
  }

  Future<void> deleteJustification(int id) async {
    await SupabaseService.instance.delete('justifications', 'id', id);
    state = state.where((item) => item.id != id).toList();
  }
}

// Provider para avisos
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final maps = await SupabaseService.instance.selectAll(
    'announcements',
    orderBy: 'created_at',
    ascending: false,
  );
  return maps.map((map) => Announcement.fromMap(map)).toList();
});

// Provider para usuarios (solo para admin)
final usersProvider = FutureProvider<List<User>>((ref) async {
  final maps = await SupabaseService.instance.selectAll(
    'users',
    orderBy: 'created_at',
    ascending: false,
  );
  return maps.map((map) => User.fromMap(map)).toList();
});

// Provider para citas
final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, List<Appointment>>((ref) {
  return AppointmentsNotifier();
});

class AppointmentsNotifier extends StateNotifier<List<Appointment>> {
  AppointmentsNotifier() : super([]) {
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final maps = await SupabaseService.instance.selectAll(
        'appointments',
        orderBy: 'appointment_date',
        ascending: false,
      );
      state = maps.map((map) => Appointment.fromMap(map)).toList();
    } catch (e) {
      // Ignorar errores iniciales de carga
      state = [];
    }
  }

  Future<void> loadAppointments() async {
    try {
      final maps = await SupabaseService.instance.selectAll(
        'appointments',
        orderBy: 'appointment_date',
        ascending: false,
      );
      state = maps.map((map) => Appointment.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    final inserted = await SupabaseService.instance.insertReturning('appointments', appointment.toMap());
    final newAppointment = Appointment(
      id: inserted['id'] as int?,
      studentId: appointment.studentId,
      orientadorId: appointment.orientadorId,
      title: appointment.title,
      description: appointment.description,
      appointmentDate: appointment.appointmentDate,
      status: appointment.status,
      createdAt: appointment.createdAt,
    );
    state = [newAppointment, ...state];

    // Registrar auditoría
    await SupabaseService.instance.logUserAction(
      appointment.orientadorId!,
      'create',
      'appointment',
      newAppointment.id,
      'Cita "${newAppointment.title}" programada para estudiante ID: ${newAppointment.studentId}',
    );
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final data = Map<String, dynamic>.from(appointment.toMap())..remove('id');
    await SupabaseService.instance.update('appointments', data, 'id', appointment.id);
    state = state.map((item) => item.id == appointment.id ? appointment : item).toList();

    // Registrar auditoría
    await SupabaseService.instance.logUserAction(
      appointment.orientadorId!,
      'update',
      'appointment',
      appointment.id,
      'Cita "${appointment.title}" actualizada - Estado: ${appointment.status}',
    );
  }

  Future<void> deleteAppointment(int id) async {
    final appointmentToDelete = state.firstWhere((appointment) => appointment.id == id);
    await SupabaseService.instance.delete('appointments', 'id', id);
    state = state.where((item) => item.id != id).toList();

    // Registrar auditoría
    await SupabaseService.instance.logUserAction(
      appointmentToDelete.orientadorId!,
      'delete',
      'appointment',
      id,
      'Cita "${appointmentToDelete.title}" eliminada',
    );
  }
}

// Provider para logs de auditoría
final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final maps = await SupabaseService.instance.selectAll(
    'audit_logs',
    orderBy: 'created_at',
    ascending: false,
  );
  return maps.map((map) => AuditLog.fromMap(map)).toList();
});

// Provider para orientadores (solo para admin)
final orientadoresProvider = FutureProvider<List<User>>((ref) async {
  final maps = await SupabaseService.instance.selectWhere(
    'users',
    {'role': 'orientador'},
    orderBy: 'created_at',
    ascending: false,
  );
  return maps.map((map) => User.fromMap(map)).toList();
});
