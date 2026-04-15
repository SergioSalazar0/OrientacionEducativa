import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class RoleDashboardScreen extends StatelessWidget {
  const RoleDashboardScreen({
    super.key,
    required this.roleId,
    required this.email,
  });

  final String roleId;
  final String email;

  String get displayName {
    final name = email.split('@').first;
    return name.isEmpty ? 'Usuario' : name;
  }

  UserRole get role {
    switch (roleId) {
      case 'padre':
      case 'usuario':
        return UserRole.usuario;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.orientador;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(role.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.go(AppRouter.home),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            role.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _RoleInfoCard(role: role),
          const SizedBox(height: 24),
          Text(
            'Hola, $displayName',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresaste como ${role.title.toLowerCase()}.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          ...role.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SectionCard(
                roleId: roleId,
                section: section,
                email: email,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (role == UserRole.admin) const _AdminNotice(),
        ],
      ),
    );
  }
}

enum UserRole { orientador, usuario, admin }

extension UserRoleInfo on UserRole {
  String get title {
    switch (this) {
      case UserRole.orientador:
        return 'Panel de Orientador';
      case UserRole.usuario:
        return 'Panel de Usuario';
      case UserRole.admin:
        return 'Panel de Administrador';
    }
  }

  String get description {
    switch (this) {
      case UserRole.orientador:
        return 'Como orientador, puedes revisar el progreso académico, gestionar citas y apoyar el desarrollo socioemocional de los estudiantes.';
      case UserRole.usuario:
        return 'Como usuario común, consulta avisos, tu perfil y contacta al orientador cuando lo necesites.';
      case UserRole.admin:
        return 'Desde este panel administrativo puedes gestionar usuarios, revisar métricas y mantener el sistema educativo en orden.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.orientador:
        return Icons.school;
      case UserRole.usuario:
        return Icons.person;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  List<RoleSection> get sections {
    switch (this) {
      case UserRole.orientador:
        return [
          RoleSection(
            featureId: 'estudiantes',
            title: 'Estudiantes pendientes',
            description:
                '4 estudiantes con seguimiento activo y citas programadas esta semana.',
            icon: Icons.person_search,
          ),
          RoleSection(
            featureId: 'agenda',
            title: 'Agenda de orientación',
            description:
                'Revisa reuniones, entrevistas y actividades de tutoría.',
            icon: Icons.calendar_today,
          ),
          RoleSection(
            featureId: 'reportes',
            title: 'Crear reportes',
            description:
                'Genera informes de seguimiento y registra recomendaciones para estudiantes.',
            icon: Icons.description,
          ),
        ];
      case UserRole.usuario:
        return [
          RoleSection(
            featureId: 'perfil',
            title: 'Mi perfil',
            description:
                'Actualiza tus datos y revisa la información básica de tu cuenta.',
            icon: Icons.account_circle,
          ),
          RoleSection(
            featureId: 'avisos',
            title: 'Avisos importantes',
            description:
                'Recibe noticias y comunicaciones de la escuela en un solo lugar.',
            icon: Icons.notification_important,
          ),
          RoleSection(
            featureId: 'contacto',
            title: 'Contactar orientador',
            description:
                'Envía una consulta rápida al equipo de orientación cuando lo necesites.',
            icon: Icons.support_agent,
          ),
        ];
      case UserRole.admin:
        return [
          RoleSection(
            featureId: 'usuarios',
            title: 'Usuarios activos',
            description:
                '108 usuarios activos, incluyendo profesores, estudiantes y familias.',
            icon: Icons.group,
          ),
          RoleSection(
            featureId: 'reportes',
            title: 'Reportes del sistema',
            description:
                'Revisa el estado general, accesos recientes y el rendimiento de la plataforma.',
            icon: Icons.bar_chart,
          ),
          RoleSection(
            featureId: 'configuracion',
            title: 'Configuración general',
            description:
                'Administra roles, permisos y políticas escolares desde aquí.',
            icon: Icons.settings,
          ),
        ];
    }
  }
}

class _RoleInfoCard extends StatelessWidget {
  const _RoleInfoCard({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(role.icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  role.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.roleId,
    required this.section,
    required this.email,
  });

  final String roleId;
  final RoleSection section;
  final String email;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.go(
        '/feature/$roleId/${section.featureId}?email=${Uri.encodeComponent(email)}',
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(section.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class RoleSection {
  const RoleSection({
    required this.featureId,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String featureId;
  final String title;
  final String description;
  final IconData icon;
}

class _AdminNotice extends StatelessWidget {
  const _AdminNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Recuerda revisar las cuentas y permisos de usuario antes de cerrar sesión.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[900]),
            ),
          ),
        ],
      ),
    );
  }
}
