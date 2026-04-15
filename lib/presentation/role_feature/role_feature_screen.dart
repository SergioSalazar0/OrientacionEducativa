import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class RoleFeatureScreen extends StatelessWidget {
  const RoleFeatureScreen({
    super.key,
    required this.roleId,
    required this.featureId,
    required this.email,
  });

  final String roleId;
  final String featureId;
  final String email;

  FeaturePage get featurePage {
    return _featureDefinitions[roleId]?[featureId] ??
        _featureDefinitions['orientador']!['estudiantes']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(featurePage.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(
            '${AppRouter.dashboard}?role=$roleId&email=${Uri.encodeComponent(email)}',
          ),
        ),
      ),
      body: _FeatureBody(
        roleId: roleId,
        featureId: featureId,
        email: email,
        featurePage: featurePage,
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
