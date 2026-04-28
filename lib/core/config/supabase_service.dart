import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  SupabaseQueryBuilder table(String name) => client.from(name);

  Future<List<Map<String, dynamic>>> selectAll(
    String table, {
    String? orderBy,
    bool ascending = true,
  }) async {
    dynamic query = client.from(table).select();
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  Future<List<Map<String, dynamic>>> selectWhere(
    String table,
    Map<String, dynamic> filters, {
    String? orderBy,
    bool ascending = true,
  }) async {
    dynamic query = client.from(table).select();
    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  Future<Map<String, dynamic>> insertReturning(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).insert(data).select().single();
    return Map<String, dynamic>.from(response as Map<String, dynamic>);
  }

  Future<void> update(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    await client.from(table).update(data).eq(column, value);
  }

  Future<void> delete(
    String table,
    String column,
    dynamic value,
  ) async {
    await client.from(table).delete().eq(column, value);
  }

  // Métodos de auditoría
  Future<void> logAuditAction({
    int? userId,
    required String action,
    required String entityType,
    int? entityId,
    required String details,
  }) async {
    try {
      await client.from('audit_logs').insert({
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
      });
    } catch (e) {
      // Si falla el logging, no queremos que detenga la operación principal
      print('Error logging audit action: $e');
    }
  }

  Future<void> logUserAction(
    int userId,
    String action,
    String entityType,
    int? entityId,
    String details,
  ) async {
    await logAuditAction(
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
    );
  }

  Future<void> logSystemAction(
    String action,
    String entityType,
    int? entityId,
    String details,
  ) async {
    await logAuditAction(
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
    );
  }
}
