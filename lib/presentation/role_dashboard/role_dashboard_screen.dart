import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class RoleDashboardScreen extends StatefulWidget {
  const RoleDashboardScreen({
    super.key,
    required this.roleId,
    required this.email,
  });

  final String roleId;
  final String email;

  @override
  State<RoleDashboardScreen> createState() => _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends State<RoleDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get displayName {
    final name = widget.email.split('@').first;
    return name.isEmpty ? 'Usuario' : name;
  }

  UserRole get role {
    switch (widget.roleId) {
      case 'padre':
      case 'usuario':
        return UserRole.usuario;
      case 'admin':
      case 'administrador':
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
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: Text(role.title),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _navigateBackWithAnimation(context),
        ),
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: const Icon(Icons.logout),
              ),
            ),
            tooltip: 'Cerrar sesión',
            onPressed: () => _showAnimatedLogoutDialog(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular el espacio disponible aproximado
        final availableHeight = constraints.maxHeight;
        final sections = role.sections;
        final estimatedCardHeight = (constraints.maxWidth / 2) * 1.1 + 16; // ancho/2 * aspectRatio + spacing
        final totalGridHeight = (sections.length / 2).ceil() * estimatedCardHeight;
        final welcomeSectionHeight = 200.0; // Estimación de la altura de la sección de bienvenida
        final totalContentHeight = welcomeSectionHeight + totalGridHeight + 50; // + padding

        // Si el contenido no cabe, reducir padding
        final padding = totalContentHeight > availableHeight ? 12.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              SizedBox(height: padding),
              _buildSectionsGrid(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value * 0.02 + 0.98, // Subtle breathing effect
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      role.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, $displayName!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          role.welcomeMessage,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Último acceso: ${DateTime.now().toString().split(' ')[0]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionsGrid() {
    final sections = role.sections;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular número de columnas basado en el ancho disponible
        final width = constraints.maxWidth;
        final crossAxisCount = width > 600 ? 3 : 2; // 3 columnas en tablets, 2 en móviles

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) => _buildAnimatedSectionCard(sections[index], index),
        );
      },
    );
  }

  Widget _buildAnimatedSectionCard(RoleSection section, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: _buildSectionCard(section),
      ),
    );
  }

  Widget _buildSectionCard(RoleSection section) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToSection(section),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  section.icon,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                section.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSection(RoleSection section) {
    // Animación de feedback táctil
    HapticFeedback.mediumImpact();

    // Animación de escala al presionar
    setState(() {});

    context.go(
      '/feature/${widget.roleId}/${section.featureId}?email=${Uri.encodeComponent(widget.email)}',
    );
  }

  void _navigateBackWithAnimation(BuildContext context) {
    HapticFeedback.lightImpact();
    context.go(AppRouter.home);
  }

  void _showAnimatedLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            const Text('¿Cerrar sesión?'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRouter.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text('Cerrar sesión'),
          ),
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

  String get welcomeMessage {
    switch (this) {
      case UserRole.orientador:
        return '¿Cómo podemos apoyar a nuestros estudiantes hoy?';
      case UserRole.usuario:
        return 'Tu bienestar académico es nuestra prioridad';
      case UserRole.admin:
        return 'Gestionando el futuro educativo de nuestra comunidad';
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
            featureId: 'citas',
            title: 'Programar citas',
            description:
                'Programa y gestiona citas de orientación con estudiantes y familias.',
            icon: Icons.schedule,
          ),
          RoleSection(
            featureId: 'avisos',
            title: 'Crear avisos',
            description:
                'Publica anuncios importantes para estudiantes y familias.',
            icon: Icons.campaign,
          ),
          RoleSection(
            featureId: 'reportes',
            title: 'Crear reportes',
            description:
                'Genera informes de seguimiento y registra recomendaciones para estudiantes.',
            icon: Icons.description,
          ),
          RoleSection(
            featureId: 'justificantes',
            title: 'Justificantes',
            description:
                'Gestiona justificantes de asistencia para los estudiantes a tu cargo.',
            icon: Icons.note_alt,
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
            featureId: 'orientadores',
            title: 'Gestionar Orientadores',
            description:
                'Crear, editar y administrar cuentas de orientadores escolares.',
            icon: Icons.person_add,
          ),
          RoleSection(
            featureId: 'auditoria',
            title: 'Auditoría del Sistema',
            description:
                'Revisar logs de actividad y movimientos en la aplicación.',
            icon: Icons.history,
          ),
          RoleSection(
            featureId: 'reportes',
            title: 'Reportes del sistema',
            description:
                'Revisa el estado general, accesos recientes y el rendimiento de la plataforma.',
            icon: Icons.bar_chart,
          ),
          RoleSection(
            featureId: 'avisos',
            title: 'Avisos y comunicados',
            description:
                'Crea y actualiza anuncios para todo el personal y las familias.',
            icon: Icons.campaign,
          ),
          RoleSection(
            featureId: 'justificantes',
            title: 'Justificantes',
            description:
                'Consulta y administra justificantes emitidos por orientación.',
            icon: Icons.assignment,
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

class _RoleInfoCard extends StatefulWidget {
  const _RoleInfoCard({required this.role});

  final UserRole role;

  @override
  State<_RoleInfoCard> createState() => _RoleInfoCardState();
}

class _RoleInfoCardState extends State<_RoleInfoCard>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bounceAnimation.value),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                  color: AppColors.primary.withOpacity(0.16),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.role.icon, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.role.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.role.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  const _SectionCard({
    required this.roleId,
    required this.section,
    required this.email,
  });

  final String roleId;
  final RoleSection section;
  final String email;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) => Transform.scale(
          scale: _hoverAnimation.value,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _navigateWithFeedback(context),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(widget.section.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.section.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.section.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateWithFeedback(BuildContext context) {
    HapticFeedback.mediumImpact();

    // Animación de escala rápida
    setState(() {});

    context.go(
      '/feature/${widget.roleId}/${widget.section.featureId}?email=${Uri.encodeComponent(widget.email)}',
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

class _AdminNotice extends StatefulWidget {
  const _AdminNotice();

  @override
  State<_AdminNotice> createState() => _AdminNoticeState();
}

class _AdminNoticeState extends State<_AdminNotice>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Recuerda revisar las cuentas y permisos de usuario antes de cerrar sesión.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[900],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
