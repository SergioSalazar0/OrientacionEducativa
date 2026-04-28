# 🎓 Orientación Educativa

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-2.0+-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

Una aplicación móvil moderna y completa para la gestión de orientación escolar, diseñada con Flutter y Supabase. Facilita la comunicación entre estudiantes, orientadores y administradores escolares a través de una interfaz intuitiva y funcionalidades especializadas por rol.

## ✨ Características Principales

### 👥 Sistema de Roles Diferenciados
- **Administrador**: Control total del sistema, gestión de usuarios y auditoría
- **Orientador**: Gestión de estudiantes, citas y reportes de seguimiento
- **Usuario**: Acceso a perfil personal y comunicación con orientadores

### 🔧 Funcionalidades por Rol

#### 🛡️ Administrador
- 👥 Gestión completa de usuarios y orientadores
- 📢 Creación y gestión de avisos institucionales
- 📊 Auditoría completa del sistema con logs detallados
- 📋 Consulta de justificantes y reportes
- ⚙️ Configuración general del sistema

#### 👨‍🏫 Orientador
- 🎓 Seguimiento de estudiantes pendientes
- 📝 Creación de reportes de orientación
- 📅 Programación y gestión de citas
- 📢 Publicación de avisos específicos
- 📋 Gestión de justificantes escolares

#### 👤 Usuario
- 👤 Gestión del perfil personal
- 📢 Consulta de avisos relevantes
- 📞 Contacto directo con orientadores

### � Características Técnicas
- **Layout Responsivo**: Adaptable a diferentes tamaños de pantalla sin overflow
- **Animaciones Suaves**: Transiciones fluidas y feedback visual
- **Gestión de Estado**: Arquitectura robusta con Riverpod
- **Navegación Declarativa**: Enrutamiento tipo web con Go Router

## 🛠️ Tecnologías Utilizadas

- **Frontend**: Flutter 3.19+ con Dart 3.3+
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Estado**: Riverpod para gestión de estado
- **Navegación**: Go Router
- **UI**: Material Design 3 con animaciones personalizadas
- **Base de datos**: PostgreSQL con Row Level Security

## 📋 Requisitos del Sistema

- **Flutter**: 3.19.0 o superior
- **Dart**: 3.3.0 o superior
- **Android**: API 21+ (Android 5.0)
- **iOS**: 12.0+
- **Web**: Chrome 88+, Firefox 85+, Safari 14+, Edge 88+

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/orientacion-educativa.git
cd orientacion-educativa
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Supabase

#### Crear Proyecto en Supabase
1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Ve a Settings > API para obtener tus credenciales

#### Configurar Variables de Entorno
Crea un archivo `.env` en la raíz del proyecto:
```env
SUPABASE_URL=tu_supabase_url
SUPABASE_ANON_KEY=tu_supabase_anon_key
```

#### Ejecutar Script de Base de Datos
Ejecuta el script SQL incluido en `audit_logs_table.sql` en el SQL Editor de Supabase:

```sql
-- Crear tabla de auditoría para logs del sistema
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER,
    details TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Desactivar RLS para esta tabla
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
```

### 4. Ejecutar la Aplicación

#### Para desarrollo web:
```bash
flutter run -d chrome
```

#### Para Android:
```bash
flutter run -d android
```

#### Para iOS (solo en macOS):
```bash
flutter run -d ios
```

## 📱 Uso de la Aplicación

### Acceso al Sistema

La aplicación determina automáticamente el rol según el correo electrónico:

| Correo | Rol | Descripción |
|--------|-----|-------------|
| `admin@escuela.com` | Administrador | Control total del sistema |
| `orientador@escuela.com` | Orientador | Gestión educativa |
| `usuario@ejemplo.com` | Usuario | Acceso básico |

**Nota**: La aplicación no incluye botones de acceso directo. Debes ingresar manualmente el correo electrónico para acceder.

## 🏗️ Arquitectura

```
lib/
├── app.dart                 # Configuración principal de la app
├── main.dart               # Punto de entrada
├── core/                   # Núcleo de la aplicación
│   ├── config/            # Configuraciones (Supabase, temas)
│   ├── constants/         # Constantes globales
│   ├── router/            # Configuración de rutas
│   └── theme/             # Tema y colores
├── data/                   # Capa de datos
│   └── models/            # Modelos de datos
├── presentation/          # Capa de presentación
│   ├── home/              # Pantalla de inicio
│   ├── role_dashboard/    # Dashboard por roles
│   ├── role_feature/      # Funcionalidades específicas
│   └── widgets/           # Componentes reutilizables
└── providers/             # Gestión de estado con Riverpod
```

### Patrones de Diseño
- **MVVM**: Separación clara entre vista y lógica
- **Provider Pattern**: Gestión de estado con Riverpod
- **Repository Pattern**: Abstracción de la capa de datos
- **Clean Architecture**: Separación de responsabilidades

## 🔍 Sistema de Auditoría

### Funcionalidades
- **Registro Automático**: Todas las operaciones CRUD generan logs
- **Vista Administrativa**: Panel completo para revisión de actividades
- **Filtros Avanzados**: Búsqueda por usuario, fecha, tipo de entidad
- **Detalles Completos**: Información específica de cada acción

### Estructura de Logs
```json
{
  "user_id": 1,
  "action": "create",
  "entity_type": "student",
  "entity_id": 123,
  "details": "Estudiante Juan Pérez creado con ID 123",
  "created_at": "2024-01-15T10:30:00Z"
}
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Guías de Contribución
- Sigue las convenciones de código de Flutter
- Agrega tests para nuevas funcionalidades
- Actualiza la documentación según sea necesario
- Asegúrate de que todos los tests pasen

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:
- 📧 Email: soporte@orientacion-educativa.com
- 🐛 Issues: [GitHub Issues](https://github.com/tu-usuario/orientacion-educativa/issues)
- 📖 Wiki: [Documentación](https://github.com/tu-usuario/orientacion-educativa/wiki)

## 🙏 Agradecimientos

- Flutter por el increíble framework
- Supabase por la plataforma backend
- Comunidad Flutter por el soporte continuo
- Equipo educativo por los requerimientos y feedback

---

**Desarrollado con ❤️ para la comunidad educativa**

Este README se puede usar como guía para exponer la aplicación y explicar sus funciones a un público técnico o administrativo.