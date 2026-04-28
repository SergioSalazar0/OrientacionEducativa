import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../providers/providers.dart';
import '../../data/models/models.dart';
import '../../core/config/supabase_service.dart';

class RoleFeatureScreen extends ConsumerStatefulWidget {
  const RoleFeatureScreen({
    super.key,
    required this.roleId,
    required this.featureId,
    required this.email,
  });

  final String roleId;
  final String featureId;
  final String email;

  @override
  ConsumerState<RoleFeatureScreen> createState() => _RoleFeatureScreenState();
}

class _RoleFeatureScreenState extends ConsumerState<RoleFeatureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  Future<void> _initializeSession() async {
    final currentSession = ref.read(sessionProvider);

    // Buscar si el usuario existe
    final maps = await SupabaseService.instance.selectWhere(
      'users',
      {'email': widget.email},
      orderBy: 'id',
      ascending: true,
    );

    if (maps.isNotEmpty) {
      // Usuario existe, cargar
      final user = User.fromMap(maps.first);
      ref.read(sessionProvider.notifier).login(user);
    } else {
      // Usuario no existe, crear en Supabase
      final defaultName = widget.email.split('@').first;
      final newUser = User(
        email: widget.email,
        role: widget.roleId,
        name: defaultName.isEmpty ? 'Usuario' : defaultName,
        phone: '',
        address: '',
      );
      try {
        final userData = Map<String, dynamic>.from(newUser.toMap())..remove('id');
        final inserted = await SupabaseService.instance.insertReturning('users', userData);
        final userWithId = User(
          id: inserted['id'] as int?,
          email: newUser.email,
          role: newUser.role,
          name: newUser.name,
          phone: newUser.phone,
          address: newUser.address,
        );
        ref.read(sessionProvider.notifier).login(userWithId);
      } catch (e) {
        // Si falla, al menos crear en memoria
        ref.read(sessionProvider.notifier).login(newUser);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_getFeatureTitle(widget.roleId, widget.featureId)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(
            '${AppRouter.dashboard}?role=${widget.roleId}&email=${Uri.encodeComponent(widget.email)}',
          ),
        ),
      ),
      body: _buildFeatureContent(),
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  String _getFeatureTitle(String roleId, String featureId) {
    switch (roleId) {
      case 'admin':
      case 'administrador':
        switch (featureId) {
          case 'usuarios':
            return 'Gestionar Usuarios';
          case 'orientadores':
            return 'Gestionar Orientadores';
          case 'auditoria':
            return 'Auditoría del Sistema';
          case 'reportes':
            return 'Reportes del Sistema';
          case 'justificantes':
            return 'Justificantes';
          case 'configuracion':
            return 'Configuración';
          case 'avisos':
            return 'Gestionar Avisos';
        }
        break;
      case 'orientador':
        switch (featureId) {
          case 'estudiantes':
            return 'Mis Estudiantes';
          case 'reportes':
            return 'Reportes';
          case 'justificantes':
            return 'Justificantes';
          case 'agenda':
            return 'Agenda';
          case 'citas':
            return 'Citas';
          case 'avisos':
            return 'Avisos';
        }
        break;
      case 'usuario':
        switch (featureId) {
          case 'perfil':
            return 'Mi Perfil';
          case 'avisos':
            return 'Avisos';
          case 'contacto':
            return 'Contactar Orientador';
        }
        break;
    }
    return 'Feature';
  }

  Widget _buildFeatureContent() {
    switch (widget.roleId) {
      case 'admin':
      case 'administrador':
        return _buildAdminContent();
      case 'orientador':
        return _buildOrientadorContent();
      case 'usuario':
        return _buildUsuarioContent();
      default:
        return const Center(child: Text('Funcionalidad no disponible'));
    }
  }

  Widget _buildAdminContent() {
    switch (widget.featureId) {
      case 'usuarios':
        return _UsersManagement();
      case 'orientadores':
        return _OrientadoresManagement();
      case 'auditoria':
        return _AuditLogsView();
      case 'reportes':
        return _ReportsView();
      case 'justificantes':
        return _JustificationsManagement();
      case 'configuracion':
        return _SettingsView();
      case 'avisos':
        return _AnnouncementsManagement();
      default:
        return const Center(child: Text('Funcionalidad no implementada'));
    }
  }

  Widget _buildOrientadorContent() {
    switch (widget.featureId) {
      case 'estudiantes':
        return _StudentsManagement();
      case 'reportes':
        return _ReportsManagement();
      case 'justificantes':
        return _JustificationsManagement();
      case 'avisos':
        return _AnnouncementsManagement();
      case 'citas':
        return _AppointmentsManagement();
      case 'agenda':
        return _AgendaView();
      default:
        return const Center(child: Text('Funcionalidad no implementada'));
    }
  }

  Widget _buildUsuarioContent() {
    switch (widget.featureId) {
      case 'perfil':
        return _ProfileEdit();
      case 'avisos':
        return _AnnouncementsView();
      case 'contacto':
        return _ContactOrientador();
      default:
        return const Center(child: Text('Funcionalidad no implementada'));
    }
  }

  Widget? _getFloatingActionButton() {
    switch (widget.roleId) {
      case 'admin':
      case 'administrador':
        if (widget.featureId == 'usuarios' || widget.featureId == 'orientadores' || widget.featureId == 'avisos' || widget.featureId == 'justificantes') {
          return FloatingActionButton(
            onPressed: () => _showAddDialog(),
            child: const Icon(Icons.add),
          );
        }
        break;
      case 'orientador':
        if (widget.featureId == 'estudiantes' || widget.featureId == 'reportes' || widget.featureId == 'justificantes' || widget.featureId == 'avisos' || widget.featureId == 'citas') {
          return FloatingActionButton(
            onPressed: () => _showAddDialog(),
            child: const Icon(Icons.add),
          );
        }
        break;
    }
    return null;
  }

  void _showAddDialog() {
    switch (widget.roleId) {
      case 'admin':
      case 'administrador':
        if (widget.featureId == 'usuarios') {
          _showAddUserDialog();
        } else if (widget.featureId == 'orientadores') {
          _showAddOrientadorDialog();
        } else if (widget.featureId == 'avisos') {
          _showAddAnnouncementDialog();
        } else if (widget.featureId == 'justificantes') {
          _showAddJustificationDialog();
        }
        break;
      case 'orientador':
        if (widget.featureId == 'estudiantes') {
          _showAddStudentDialog();
        } else if (widget.featureId == 'reportes') {
          _showAddReportDialog();
        } else if (widget.featureId == 'justificantes') {
          _showAddJustificationDialog();
        } else if (widget.featureId == 'avisos') {
          _showAddAnnouncementDialog();
        } else if (widget.featureId == 'citas') {
          _showAddAppointmentDialog();
        }
        break;
    }
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String selectedRole = 'usuario';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(value: 'orientador', child: Text('Orientador')),
                  DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                ],
                onChanged: (value) => selectedRole = value!,
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                final user = User(
                  email: emailController.text,
                  role: selectedRole,
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                );
                final userData = Map<String, dynamic>.from(user.toMap())..remove('id');
                await SupabaseService.instance.insertReturning('users', userData);
                ref.invalidate(usersProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario agregado')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedRole = 'usuario';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Aviso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              items: const [
                DropdownMenuItem(value: 'usuario', child: Text('Usuarios')),
                DropdownMenuItem(value: 'orientador', child: Text('Orientadores')),
                DropdownMenuItem(value: 'administrador', child: Text('Administradores')),
              ],
              onChanged: (value) => selectedRole = value!,
              decoration: const InputDecoration(labelText: 'Dirigido a'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                final announcement = Announcement(
                  title: titleController.text,
                  description: descriptionController.text,
                  targetRole: selectedRole,
                );
                final announcementData = Map<String, dynamic>.from(announcement.toMap())..remove('id');
                await SupabaseService.instance.insertReturning('announcements', announcementData);
                ref.invalidate(announcementsProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aviso agregado')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    String selectedStatus = 'Requiere apoyo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Estudiante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Grado'),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: const [
                DropdownMenuItem(value: 'Requiere apoyo', child: Text('Requiere apoyo')),
                DropdownMenuItem(value: 'En seguimiento', child: Text('En seguimiento')),
                DropdownMenuItem(value: 'Caso cerrado', child: Text('Caso cerrado')),
              ],
              onChanged: (value) => selectedStatus = value!,
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && gradeController.text.isNotEmpty) {
                final session = ref.read(sessionProvider)!;
                final student = Student(
                  name: nameController.text,
                  grade: gradeController.text,
                  status: selectedStatus,
                  orientadorId: session.id,
                );
                final data = Map<String, dynamic>.from(student.toMap())..remove('id');
                await SupabaseService.instance.insertReturning('students', data);
                ref.invalidate(studentsProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estudiante agregado')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    Student? selectedStudent;
    DateTime appointmentDate = DateTime.now();
    String selectedStatus = 'programada';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Programar Cita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final studentsAsync = ref.watch(studentsProvider);
                    return studentsAsync.when(
                      data: (students) => DropdownButtonFormField<Student>(
                        value: selectedStudent,
                        items: students.map<DropdownMenuItem<Student>>((student) => DropdownMenuItem<Student>(
                          value: student,
                          child: Text(student.name.isNotEmpty ? student.name : 'Sin nombre'),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedStudent = value),
                        decoration: const InputDecoration(labelText: 'Estudiante'),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${appointmentDate.day.toString().padLeft(2, '0')}/${appointmentDate.month.toString().padLeft(2, '0')}/${appointmentDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: appointmentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            appointmentDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'programada', child: Text('Programada')),
                    DropdownMenuItem(value: 'completada', child: Text('Completada')),
                    DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedStudent != null && titleController.text.isNotEmpty) {
                  final session = ref.read(sessionProvider)!;
                  final appointment = Appointment(
                    studentId: selectedStudent!.id,
                    orientadorId: session.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    appointmentDate: appointmentDate,
                    status: selectedStatus,
                  );
                  await ref.read(appointmentsProvider.notifier).addAppointment(appointment);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cita programada')),
                  );
                }
              },
              child: const Text('Programar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddJustificationDialog() {
    final titleController = TextEditingController();
    final reasonController = TextEditingController();
    Student? selectedStudent;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear Justificante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final studentsAsync = ref.watch(studentsProvider);
                    return studentsAsync.when(
                      data: (students) => DropdownButtonFormField<Student>(
                        initialValue: selectedStudent,
                        items: students.map<DropdownMenuItem<Student>>((student) => DropdownMenuItem<Student>(
                          value: student,
                          child: Text(student?.name ?? 'Sin nombre'),
                        )).toList(),
                        onChanged: (value) => selectedStudent = value as Student?,
                        decoration: const InputDecoration(labelText: 'Estudiante'),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Razón'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedStudent != null && titleController.text.isNotEmpty) {
                  final session = ref.read(sessionProvider)!;
                  final justification = Justification(
                    studentId: selectedStudent!.id,
                    orientadorId: session.id,
                    title: titleController.text,
                    reason: reasonController.text,
                    dateIssued: selectedDate,
                  );
                  ref.read(justificationsProvider.notifier).addJustification(justification);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Justificante creado')),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReportDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final followUpController = TextEditingController();
    Student? selectedStudent;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Reporte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final studentsAsync = ref.watch(studentsProvider);
                  return studentsAsync.when(
                    data: (students) => DropdownButtonFormField<Student>(
                      initialValue: selectedStudent,
                      items: students.map<DropdownMenuItem<Student>>((student) => DropdownMenuItem<Student>(
                        value: student,
                        child: Text(student?.name ?? 'Sin nombre'),
                      )).toList(),
                      onChanged: (value) => selectedStudent = value as Student?,
                      decoration: const InputDecoration(labelText: 'Estudiante'),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextField(
                controller: followUpController,
                decoration: const InputDecoration(labelText: 'Seguimiento'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedStudent != null && titleController.text.isNotEmpty) {
                final session = ref.read(sessionProvider)!;
                final report = Report(
                  studentId: selectedStudent!.id,
                  orientadorId: session.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  followUp: followUpController.text,
                );
                ref.read(reportsProvider.notifier).addReport(report);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reporte creado')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showAddOrientadorDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Orientador'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                final orientador = User(
                  email: emailController.text,
                  role: 'orientador',
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                );
                final userData = Map<String, dynamic>.from(orientador.toMap())..remove('id');
                await SupabaseService.instance.insertReturning('users', userData);
                ref.invalidate(orientadoresProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orientador agregado exitosamente')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

// Widget para gestión de orientadores
class _OrientadoresManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientadoresAsync = ref.watch(orientadoresProvider);

    return orientadoresAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (orientadores) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orientadores.length,
        itemBuilder: (context, index) {
          final orientador = orientadores[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(orientador.name.isNotEmpty ? orientador.name[0].toUpperCase() : 'O'),
              ),
              title: Text(orientador.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orientador.email),
                  Text(
                    'Tel: ${orientador.phone} · ${orientador.address}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleOrientadorAction(context, ref, orientador, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleOrientadorAction(BuildContext context, WidgetRef ref, User orientador, String action) {
    switch (action) {
      case 'edit':
        _showEditOrientadorDialog(context, ref, orientador);
        break;
      case 'delete':
        _showDeleteOrientadorDialog(context, ref, orientador);
        break;
    }
  }

  void _showEditOrientadorDialog(BuildContext context, WidgetRef ref, User orientador) {
    final nameController = TextEditingController(text: orientador.name);
    final phoneController = TextEditingController(text: orientador.phone);
    final addressController = TextEditingController(text: orientador.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Orientador'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final updatedOrientador = User(
                id: orientador.id,
                email: orientador.email,
                role: orientador.role,
                name: nameController.text,
                phone: phoneController.text,
                address: addressController.text,
              );
              final data = Map<String, dynamic>.from(updatedOrientador.toMap())..remove('id');
              await SupabaseService.instance.update('users', data, 'id', orientador.id);
              ref.invalidate(orientadoresProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orientador actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteOrientadorDialog(BuildContext context, WidgetRef ref, User orientador) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Orientador'),
        content: Text('¿Estás seguro de eliminar a ${orientador.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await SupabaseService.instance.delete('users', 'id', orientador.id);
              ref.invalidate(orientadoresProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orientador eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Widget para vista de auditoría/logs
class _AuditLogsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);

    return auditLogsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (logs) => logs.isEmpty
          ? const Center(child: Text('No hay registros de auditoría disponibles.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getActionIcon(log.action),
                      color: _getActionColor(log.action),
                    ),
                    title: Text('${log.action.toUpperCase()} - ${log.entityType}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.details),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDateTime(log.createdAt)} · Usuario: ${log.userId ?? 'Sistema'}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Icons.add_circle;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'login':
        return Colors.purple;
      case 'logout':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} $hour:$minute';
  }
}

// Widgets para funcionalidades CRUD

class _UsersManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (users) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
              ),
              title: Text(user.name),
              subtitle: Text('${user.email} - ${user.role}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(context, ref, user, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleUserAction(BuildContext context, WidgetRef ref, User user, String action) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, ref, user);
        break;
      case 'delete':
        _showDeleteUserDialog(context, ref, user);
        break;
    }
  }

  void _showEditUserDialog(BuildContext context, WidgetRef ref, User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final addressController = TextEditingController(text: user.address);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(value: 'orientador', child: Text('Orientador')),
                  DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                ],
                onChanged: (value) => selectedRole = value!,
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = User(
                id: user.id,
                email: user.email,
                role: selectedRole,
                name: nameController.text,
                phone: phoneController.text,
                address: addressController.text,
              );
              final data = Map<String, dynamic>.from(updatedUser.toMap())..remove('id');
              await SupabaseService.instance.update('users', data, 'id', user.id);
              ref.invalidate(usersProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de eliminar a ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await SupabaseService.instance.delete('users', 'id', user.id);
              ref.invalidate(usersProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return announcementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (announcements) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(announcement.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(announcement.description),
                  Text(
                    'Para: ${announcement.targetRole} - ${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleAnnouncementAction(context, ref, announcement, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAnnouncementAction(BuildContext context, WidgetRef ref, Announcement announcement, String action) {
    switch (action) {
      case 'edit':
        _showEditAnnouncementDialog(context, ref, announcement);
        break;
      case 'delete':
        _showDeleteAnnouncementDialog(context, ref, announcement);
        break;
    }
  }

  void _showEditAnnouncementDialog(BuildContext context, WidgetRef ref, Announcement announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final descriptionController = TextEditingController(text: announcement.description);
    String selectedRole = announcement.targetRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Aviso'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuarios')),
                  DropdownMenuItem(value: 'orientador', child: Text('Orientadores')),
                  DropdownMenuItem(value: 'administrador', child: Text('Administradores')),
                ],
                onChanged: (value) => selectedRole = value!,
                decoration: const InputDecoration(labelText: 'Dirigido a'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final updatedAnnouncement = Announcement(
                id: announcement.id,
                title: titleController.text,
                description: descriptionController.text,
                targetRole: selectedRole,
                createdAt: announcement.createdAt,
              );
              final data = Map<String, dynamic>.from(updatedAnnouncement.toMap())..remove('id');
              await SupabaseService.instance.update('announcements', data, 'id', announcement.id);
              ref.invalidate(announcementsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aviso actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAnnouncementDialog(BuildContext context, WidgetRef ref, Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Aviso'),
        content: Text('¿Estás seguro de eliminar "${announcement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await SupabaseService.instance.delete('announcements', 'id', announcement.id);
              ref.invalidate(announcementsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aviso eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);

    return appointments.isEmpty
        ? const Center(child: Text('No hay citas programadas.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: AppColors.primary),
                  title: Text(appointment.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.description),
                      const SizedBox(height: 4),
                      Text(
                        'Estudiante: ${appointment.studentId ?? 'N/A'} · ${_formatAppointmentDate(appointment.appointmentDate)} · ${appointment.status}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleAppointmentAction(context, ref, appointment, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
  }

  String _formatAppointmentDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  void _handleAppointmentAction(BuildContext context, WidgetRef ref, Appointment appointment, String action) {
    switch (action) {
      case 'edit':
        _showEditAppointmentDialog(context, ref, appointment);
        break;
      case 'delete':
        _showDeleteAppointmentDialog(context, ref, appointment);
        break;
    }
  }

  void _showEditAppointmentDialog(BuildContext context, WidgetRef ref, Appointment appointment) {
    final titleController = TextEditingController(text: appointment.title);
    final descriptionController = TextEditingController(text: appointment.description);
    String selectedStatus = appointment.status;
    DateTime appointmentDate = appointment.appointmentDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Cita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${_formatAppointmentDate(appointmentDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: appointmentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            appointmentDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              appointmentDate.hour,
                              appointmentDate.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'programada', child: Text('Programada')),
                    DropdownMenuItem(value: 'completada', child: Text('Completada')),
                    DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        // ignore: prefer_final_locals
                        // Use local variable selectedStatus for modifications.
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final updated = Appointment(
                  id: appointment.id,
                  studentId: appointment.studentId,
                  orientadorId: appointment.orientadorId,
                  title: titleController.text,
                  description: descriptionController.text,
                  appointmentDate: appointmentDate,
                  status: selectedStatus,
                  createdAt: appointment.createdAt,
                );
                final data = Map<String, dynamic>.from(updated.toMap())..remove('id');
                await SupabaseService.instance.update('appointments', data, 'id', updated.id);
                ref.invalidate(appointmentsProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cita actualizada')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAppointmentDialog(BuildContext context, WidgetRef ref, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content: Text('¿Estás seguro de eliminar la cita "${appointment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await SupabaseService.instance.delete('appointments', 'id', appointment.id);
              ref.invalidate(appointmentsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cita eliminada')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StudentsManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (students) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(student.status),
                child: Text(student.name.isNotEmpty ? student.name[0].toUpperCase() : 'E'),
              ),
              title: Text(student.name),
              subtitle: Text('${student.grade} - ${student.status}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleStudentAction(context, ref, student, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Requiere apoyo':
        return Colors.red;
      case 'En seguimiento':
        return Colors.orange;
      case 'Caso cerrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleStudentAction(BuildContext context, WidgetRef ref, Student student, String action) {
    switch (action) {
      case 'edit':
        _showEditStudentDialog(context, ref, student);
        break;
      case 'delete':
        _showDeleteStudentDialog(context, ref, student);
        break;
    }
  }

  void _showEditStudentDialog(BuildContext context, WidgetRef ref, Student student) {
    final nameController = TextEditingController(text: student.name);
    final gradeController = TextEditingController(text: student.grade);
    String selectedStatus = student.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Estudiante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Grado'),
            ),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(value: 'Requiere apoyo', child: Text('Requiere apoyo')),
                DropdownMenuItem(value: 'En seguimiento', child: Text('En seguimiento')),
                DropdownMenuItem(value: 'Caso cerrado', child: Text('Caso cerrado')),
              ],
              onChanged: (value) => selectedStatus = value!,
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final updatedStudent = Student(
                id: student.id,
                name: nameController.text,
                grade: gradeController.text,
                status: selectedStatus,
                orientadorId: student.orientadorId,
              );
              final data = Map<String, dynamic>.from(updatedStudent.toMap())..remove('id');
              await SupabaseService.instance.update('students', data, 'id', student.id);
              ref.invalidate(studentsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estudiante actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteStudentDialog(BuildContext context, WidgetRef ref, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Estudiante'),
        content: Text('¿Estás seguro de eliminar a ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await SupabaseService.instance.delete('students', 'id', student.id);
              ref.invalidate(studentsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estudiante eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ReportsManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(report.title),
            subtitle: Text(
              'Creado: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(report.description),
                    const SizedBox(height: 8),
                    if (report.followUp.isNotEmpty) ...[
                      Text('Seguimiento:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(report.followUp),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showEditReportDialog(context, ref, report),
                          child: const Text('Editar'),
                        ),
                        TextButton(
                          onPressed: () => _showDeleteReportDialog(context, ref, report),
                          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showEditReportDialog(BuildContext context, WidgetRef ref, Report report) {
    final titleController = TextEditingController(text: report.title);
    final descriptionController = TextEditingController(text: report.description);
    final followUpController = TextEditingController(text: report.followUp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Reporte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextField(
                controller: followUpController,
                decoration: const InputDecoration(labelText: 'Seguimiento'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final updatedReport = Report(
                id: report.id,
                studentId: report.studentId,
                orientadorId: report.orientadorId,
                title: titleController.text,
                description: descriptionController.text,
                followUp: followUpController.text,
                createdAt: report.createdAt,
              );
              final data = Map<String, dynamic>.from(updatedReport.toMap())..remove('id');
              await SupabaseService.instance.update('reports', data, 'id', report.id);
              ref.invalidate(reportsProvider);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReportDialog(BuildContext context, WidgetRef ref, Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content: Text('¿Estás seguro de eliminar "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(reportsProvider.notifier).deleteReport(report.id!);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _JustificationsManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final justifications = ref.watch(justificationsProvider);
    final studentsAsync = ref.watch(studentsProvider);

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (students) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: justifications.length,
        itemBuilder: (context, index) {
          final justification = justifications[index];
          final student = students.firstWhere(
            (item) => item.id == justification.studentId,
            orElse: () => Student(id: justification.studentId, name: 'Estudiante desconocido', grade: '', status: '', orientadorId: null),
          );
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(justification.title),
              subtitle: Text(
                'Alumno: ${student.name} - Fecha: ${justification.dateIssued.day}/${justification.dateIssued.month}/${justification.dateIssued.year}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Razón:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(justification.reason),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showEditJustificationDialog(context, ref, justification),
                            child: const Text('Editar'),
                          ),
                          TextButton(
                            onPressed: () => _showDeleteJustificationDialog(context, ref, justification),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditJustificationDialog(BuildContext context, WidgetRef ref, Justification justification) {
    final titleController = TextEditingController(text: justification.title);
    final reasonController = TextEditingController(text: justification.reason);
    Student? selectedStudent;
    DateTime selectedDate = justification.dateIssued;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Justificante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final studentsAsync = ref.watch(studentsProvider);
                    return studentsAsync.when(
                      data: (students) {
                        final selectedValue = students.firstWhere(
                          (item) => item.id == justification.studentId,
                          orElse: () => Student(
                            id: null,
                            name: '',
                            grade: '',
                            status: '',
                            orientadorId: null,
                          ),
                        );
                        return DropdownButtonFormField<Student>(
                          value: selectedValue.id == null ? null : selectedValue,
                          items: students.map<DropdownMenuItem<Student>>((student) => DropdownMenuItem<Student>(
                            value: student,
                            child: Text(student.name),
                          )).toList(),
                          onChanged: (value) => selectedStudent = value as Student?,
                          decoration: const InputDecoration(labelText: 'Estudiante'),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Razón'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final updatedJustification = Justification(
                  id: justification.id,
                  studentId: selectedStudent?.id ?? justification.studentId,
                  orientadorId: justification.orientadorId,
                  title: titleController.text,
                  reason: reasonController.text,
                  dateIssued: selectedDate,
                  createdAt: justification.createdAt,
                );
                await ref.read(justificationsProvider.notifier).updateJustification(updatedJustification);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Justificante actualizado')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteJustificationDialog(BuildContext context, WidgetRef ref, Justification justification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Justificante'),
        content: Text('¿Estás seguro de eliminar "${justification.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(justificationsProvider.notifier).deleteJustification(justification.id!);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Justificante eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileEdit extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends ConsumerState<_ProfileEdit> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    _nameController = TextEditingController(text: session?.name ?? '');
    _phoneController = TextEditingController(text: session?.phone ?? '');
    _addressController = TextEditingController(text: session?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editar Mi Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: session.email),
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            enabled: false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Cambios'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    final session = ref.read(sessionProvider);
    if (session != null) {
      ref.read(sessionProvider.notifier).updateProfile(
        _nameController.text,
        _phoneController.text,
        _addressController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }
}

class _AnnouncementsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return announcementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (announcements) {
        final userAnnouncements = announcements.where((a) => a.targetRole == 'usuario').toList();
        if (userAnnouncements.isEmpty) {
          return const Center(
            child: Text(
              'No hay avisos disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userAnnouncements.length,
          itemBuilder: (context, index) {
            final announcement = userAnnouncements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(announcement.description),
                    const SizedBox(height: 8),
                    Text(
                      'Publicado: ${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactOrientador extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (users) {
        final orientadores = users.where((u) => u.role == 'orientador').toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orientadores.length,
          itemBuilder: (context, index) {
            final orientador = orientadores[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(orientador.name.isNotEmpty ? orientador.name[0].toUpperCase() : 'O'),
                ),
                title: Text(orientador.name),
                subtitle: Text(orientador.email),
                trailing: IconButton(
                  icon: const Icon(Icons.contact_mail),
                  onPressed: () => _showContactDialog(context, orientador),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showContactDialog(BuildContext context, User orientador) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a ${orientador.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${orientador.email}'),
            if (orientador.phone.isNotEmpty) Text('Teléfono: ${orientador.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Aquí se podría implementar envío de email o notificación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mensaje enviado a ${orientador.name}')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

// Reportes del Sistema (Admin)
class _ReportsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return reportsAsync.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportsAsync.length,
            itemBuilder: (context, index) {
              final report = reportsAsync[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(report.title),
                  subtitle: Text(
                    'Creado: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(report.description),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}

// Configuración del Sistema (Admin)
class _SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración del Sistema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información del Sistema'),
              subtitle: const Text('Versión 1.0.0'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sistema listo')),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Base de Datos'),
              subtitle: const Text('Supabase Conectado'),
            ),
          ),
        ],
      ),
    );
  }
}

// Agenda del Orientador
class _AgendaView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agenda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Próximas citas:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Seguimiento a estudiantes'),
                    subtitle: Text('Hoy a las 10:00 AM'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBody extends StatefulWidget {
  const _FeatureBody({
    required this.roleId,
    required this.featureId,
    required this.email,
    required this.featurePage,
  });

  final String roleId;
  final String featureId;
  final String email;
  final FeaturePage featurePage;

  @override
  State<_FeatureBody> createState() => _FeatureBodyState();
}

class _FeatureBodyState extends State<_FeatureBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _reportStudentController;
  late final TextEditingController _reportDescriptionController;
  late final TextEditingController _reportFollowUpController;
  late List<FeatureCardData> _reportCards;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.email.split('@').first,
    );
    _phoneController = TextEditingController(text: '+52 55 1234 5678');
    _addressController = TextEditingController(text: 'Calle Falsa 123');
    _reportStudentController = TextEditingController();
    _reportDescriptionController = TextEditingController();
    _reportFollowUpController = TextEditingController();
    _reportCards = [
      FeatureCardData(
        icon: Icons.description,
        title: 'Informe inicial',
        description:
            'Reporte de seguimiento para los estudiantes con apoyo personalizado.',
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reportStudentController.dispose();
    _reportDescriptionController.dispose();
    _reportFollowUpController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos para guardar tu perfil.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente.')),
    );
  }

  void _addReport() {
    final student = _reportStudentController.text.trim();
    final description = _reportDescriptionController.text.trim();
    final followUp = _reportFollowUpController.text.trim();

    if (student.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa el nombre del estudiante y el contenido del reporte.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _reportCards.insert(
        0,
        FeatureCardData(
          icon: Icons.description,
          title: 'Reporte para $student',
          description: description,
          leadingValue: followUp.isNotEmpty ? 'Seguimiento: $followUp' : null,
        ),
      );
      _reportStudentController.clear();
      _reportDescriptionController.clear();
      _reportFollowUpController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte creado exitosamente.')),
    );
  }

  Widget _buildProfileEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Editar información personal',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Crear nuevo reporte',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reportStudentController,
            decoration: const InputDecoration(
              labelText: 'Nombre del estudiante',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reportDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción del reporte',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reportFollowUpController,
            decoration: const InputDecoration(
              labelText: 'Seguimiento recomendado',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _addReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Guardar reporte'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featurePage = widget.featurePage;
    final List<Widget> bodyItems = [
      Text(
        featurePage.subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: Colors.grey[800], height: 1.4),
      ),
      if (widget.email.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          'Sesión: ${widget.email.split('@').first}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        ),
      ],
      const SizedBox(height: 20),
    ];

    if (widget.roleId == 'usuario' && widget.featureId == 'perfil') {
      bodyItems.addAll([
        _buildProfileEditor(context),
        const SizedBox(height: 24),
        Text(
          'Resumen de tu cuenta',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...featurePage.cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeatureCard(card: card),
          ),
        ),
      ]);
    } else if (widget.roleId == 'orientador' &&
        widget.featureId == 'reportes') {
      bodyItems.addAll([
        _buildReportEditor(context),
        const SizedBox(height: 24),
        Text(
          'Reportes recientes',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._reportCards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeatureCard(card: card),
          ),
        ),
      ]);
    } else {
      bodyItems.addAll(
        featurePage.cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeatureCard(card: card),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: bodyItems,
    );
  }
}

class FeaturePage {
  const FeaturePage({
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  final String title;
  final String subtitle;
  final List<FeatureCardData> cards;
}

class FeatureCardData {
  const FeatureCardData({
    required this.title,
    required this.description,
    required this.icon,
    this.leadingValue,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? leadingValue;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.card});

  final FeatureCardData card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(card.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                if (card.leadingValue != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    card.leadingValue!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final Map<String, Map<String, FeaturePage>> _featureDefinitions = {
  'orientador': {
    'estudiantes': FeaturePage(
      title: 'Estudiantes pendientes',
      subtitle:
          'Encuentra la lista de estudiantes en seguimiento y revisa sus notas recientes.',
      cards: [
        FeatureCardData(
          icon: Icons.person,
          title: 'Ana Pérez',
          description: 'Necesita acompañamiento en habilidades sociales.',
          leadingValue: 'Nivel: Medio',
        ),
        FeatureCardData(
          icon: Icons.person,
          title: 'Carlos López',
          description:
              'Avance académico estable, seguimiento de la agenda pendiente.',
        ),
        FeatureCardData(
          icon: Icons.person,
          title: 'María Torres',
          description: 'Entrevista de orientación programada para el jueves.',
        ),
      ],
    ),
    'agenda': FeaturePage(
      title: 'Agenda de orientación',
      subtitle:
          'Revisa tu calendario de tutorías, entrevistas y actividades de acompañamiento.',
      cards: [
        FeatureCardData(
          icon: Icons.calendar_today,
          title: 'Entrevista con la familia de Ana',
          description: 'Miércoles 10:00 AM, sala de tutoría.',
          leadingValue: 'Estado: Confirmado',
        ),
        FeatureCardData(
          icon: Icons.calendar_today,
          title: 'Taller de habilidades socioemocionales',
          description: 'Viernes 2:00 PM, aula 5.',
        ),
      ],
    ),
    'recomendaciones': FeaturePage(
      title: 'Recomendaciones',
      subtitle:
          'Guías y acciones para mejorar la experiencia de los estudiantes.',
      cards: [
        FeatureCardData(
          icon: Icons.lightbulb,
          title: 'Apoyo a la lectura',
          description: 'Incentivar lectura diaria con fichas de comprensión.',
        ),
        FeatureCardData(
          icon: Icons.lightbulb,
          title: 'Fortalecer resiliencia',
          description: 'Aplicar dinámicas de grupo semanalmente.',
        ),
      ],
    ),
  },
  'usuario': {
    'perfil': FeaturePage(
      title: 'Mi perfil',
      subtitle: 'Consulta y actualiza tus datos personales y de contacto.',
      cards: [
        FeatureCardData(
          icon: Icons.account_circle,
          title: 'Información personal',
          description: 'Revisa tus datos y actualiza tu teléfono o dirección.',
        ),
        FeatureCardData(
          icon: Icons.privacy_tip,
          title: 'Seguridad de la cuenta',
          description: 'Cambia tu contraseña y revisa los accesos recientes.',
        ),
      ],
    ),
    'avisos': FeaturePage(
      title: 'Avisos importantes',
      subtitle: 'Revisa comunicados y actualizaciones de la escuela.',
      cards: [
        FeatureCardData(
          icon: Icons.notification_important,
          title: 'Cambio de horario',
          description: 'Nueva jornada académica a partir del lunes.',
        ),
        FeatureCardData(
          icon: Icons.notification_important,
          title: 'Reunión escolar',
          description:
              'Invitación a reunión de seguimiento el viernes a las 5 PM.',
        ),
      ],
    ),
    'contacto': FeaturePage(
      title: 'Contactar orientador',
      subtitle: 'Envía una consulta rápida al equipo de orientación.',
      cards: [
        FeatureCardData(
          icon: Icons.support_agent,
          title: 'Enviar mensaje',
          description: 'Escribe tus dudas y solicita apoyo educativo.',
        ),
        FeatureCardData(
          icon: Icons.schedule,
          title: 'Solicitar cita',
          description: 'Agenda una entrevista con el orientador escolar.',
        ),
      ],
    ),
  },
  'admin': {
    'usuarios': FeaturePage(
      title: 'Usuarios activos',
      subtitle: 'Revisa el conteo de cuentas en el sistema y su estado.',
      cards: [
        FeatureCardData(
          icon: Icons.group,
          title: 'Administradores',
          description: '5 cuentas activas con permisos completos.',
          leadingValue: '5 usuarios',
        ),
        FeatureCardData(
          icon: Icons.group,
          title: 'Padres de familia',
          description: '42 cuentas registradas en el último mes.',
          leadingValue: '42 usuarios',
        ),
      ],
    ),
    'reportes': FeaturePage(
      title: 'Reportes del sistema',
      subtitle: 'Indicadores clave de uso y salud de la plataforma.',
      cards: [
        FeatureCardData(
          icon: Icons.bar_chart,
          title: 'Sesiones de esta semana',
          description: 'La plataforma registró 156 accesos.',
          leadingValue: '156',
        ),
        FeatureCardData(
          icon: Icons.bar_chart,
          title: 'Alertas de mantenimiento',
          description: '2 actualizaciones pendientes en el módulo de informes.',
        ),
      ],
    ),
    'configuracion': FeaturePage(
      title: 'Configuración general',
      subtitle: 'Ajusta permisos, políticas y paramétricas institucionales.',
      cards: [
        FeatureCardData(
          icon: Icons.settings,
          title: 'Roles y permisos',
          description: 'Define qué pueden ver y hacer los diferentes perfiles.',
        ),
        FeatureCardData(
          icon: Icons.shield,
          title: 'Seguridad',
          description: 'Actualiza políticas de acceso y autenticación.',
        ),
      ],
    ),
  },
};
