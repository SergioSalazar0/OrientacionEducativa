# Guía de Presentación - Orientación Educativa

Esta guía está pensada para mostrar la aplicación en una presentación técnica o a un público administrativo. Está enfocada en los puntos clave, el flujo de demo y los mensajes que se deben transmitir.

## 1. Objetivo de la presentación

- Mostrar cómo la aplicación soporta la **gestión de orientación escolar** con roles diferenciados.
- Destacar la **experiencia de usuario** en cada perfil: administrador, orientador y usuario.
- Visualizar la **capacidad de auditoría y control** del sistema.
- Probar el flujo de creación, edición y consulta de datos en tiempo real.

## 2. Mensaje principal

Esta aplicación está diseñada para facilitar la labor escolar de orientación mediante:

- **Roles claros y separados** que definen permisos y funcionalidades.
- **Interfaz sencilla e intuitiva** para usuarios administrativos y docentes.
- **Registro de actividad y auditoría** para monitoreo del sistema.
- **Conexión con backend** para que los datos se actualicen de forma confiable.

## 3. Flujo recomendado de la demo

### 3.1 Inicio de la presentación

1. Presenta el objetivo general: acompañar a estudiantes, orientadores y administración escolar.
2. Muestra la pantalla de inicio y explica que el acceso se hace con correo electrónico.
3. Comenta que el rol se determina por el correo ingresado y que la app no usa botones de acceso directo.

### 3.2 Demo del rol Administrador

1. Inicia sesión con `admin@escuela.com`.
2. Navega por el dashboard de administrador.
3. Muestra:
   - Gestión de usuarios
   - Gestión de orientadores
   - Panel de auditoría del sistema
   - Creación de avisos y justificantes
   - Sección de reportes del sistema
4. Explica el valor de la auditoría: seguimiento de acciones críticas y control de cambios.

### 3.3 Demo del rol Orientador

1. Inicia sesión con `orientador@escuela.com`.
2. Muestra:
   - Estudiantes pendientes
   - Agenda de orientación
   - Programación de citas
   - Creación de reportes
   - Publicación de avisos
3. Resalta cómo el orientador puede registrar fácilmente el seguimiento académico y socioemocional.

### 3.4 Demo del rol Usuario

1. Inicia sesión con un correo de usuario cualquiera.
2. Muestra:
   - Actualización de perfil
   - Consulta de avisos
   - Contacto con orientador
3. Explica que el usuario tiene acceso seguro y limitado a su propia información.

## 4. Qué mostrar en pantalla

- **Dashboard principal**: estructura por rol y diseño responsivo.
- **Formulario de login**: acceso simple con email.
- **Tarjetas de rol**: vistas limpias y botones claros.
- **CRUD en secciones**: agregar, editar, eliminar registros.
- **Panel de auditoría**: logs y detalles de acciones del sistema.

## 5. Puntos técnicos para enfatizar

- Está desarrollado con **Flutter**, lo que permite ejecución en web, Android e iOS.
- Utiliza **Go Router** para navegación declarativa.
- Usa **Riverpod** para manejar estado de forma segura.
- El backend está pensado para **Supabase / PostgreSQL** con tablas de auditoría.
- La interfaz se adapta a distintos tamaños de pantalla para evitar errores de overflow.

## 6. Recomendaciones para la exposición

- Habla en términos de **beneficios** más que de funciones.
- Explica la **propósito educativo** de cada rol.
- Resalta la **seguridad** y la captura de actividad del sistema.
- Si hay tiempo, muestra cómo se ve en **modo móvil y modo web**.
- Menciona que la app está lista para ser escalada con más roles y datos.

## 7. Ejemplo de guion rápido

1. "Esta aplicación apoya la orientación escolar con tres perfiles definidos."
2. "Voy a mostrar primero el perfil de administrador..."
3. "Aquí el administrador puede supervisar la plataforma y revisar logs de auditoría..."
4. "Luego lo que ve el orientador: estudiantes, citas y reportes..."
5. "Finalmente, el usuario común puede actualizar su perfil y ver avisos..."
6. "Este flujo garantiza control, transparencia y una experiencia clara para cada usuario."

## 8. Consideraciones finales

- Si se presenta a directores o equipos pedagógicos, enfatiza la **supervisión y trazabilidad**.
- Si se presenta a desarrolladores, menciona la **arquitectura modular** y los componentes reutilizables.
- Si se presenta a usuarios finales, habla del **ahorro de tiempo** y la **facilidad de uso**.

---

**Esta guía está pensada para ayudarte a presentar la aplicación de forma clara, estructurada y efectiva.**