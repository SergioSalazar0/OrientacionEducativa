# Esquema de Supabase para Orientación Educativa

Este documento describe las tablas necesarias para que la app funcione con una base de datos en Supabase.
Se incluyen los campos, relaciones y ejemplos de inicialización.

---

## Tablas necesarias

### 1. `users`
Representa a los usuarios del sistema: administradores, orientadores y usuarios comunes.

```sql
CREATE TABLE public.users (
  id bigserial PRIMARY KEY,
  email text UNIQUE NOT NULL,
  role text NOT NULL,
  name text NOT NULL,
  phone text,
  address text,
  created_at timestamptz DEFAULT now()
);
```

Valores de `role` usados en la app:
- `administrador`
- `orientador`
- `usuario`

### 2. `students`
Contiene los estudiantes registrados y su vínculo con el orientador encargado.

```sql
CREATE TABLE public.students (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  grade text NOT NULL,
  status text NOT NULL,
  orientador_id bigint REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);
```

### 3. `reports`
Almacena los reportes de seguimiento creados por los orientadores.

```sql
CREATE TABLE public.reports (
  id bigserial PRIMARY KEY,
  student_id bigint REFERENCES public.students(id) ON DELETE CASCADE,
  orientador_id bigint REFERENCES public.users(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text NOT NULL,
  follow_up text,
  created_at timestamptz DEFAULT now()
);
```

### 4. `justifications`
Registra justificantes de asistencia o faltas asociados a estudiantes.

```sql
CREATE TABLE public.justifications (
  id bigserial PRIMARY KEY,
  student_id bigint REFERENCES public.students(id) ON DELETE CASCADE,
  orientador_id bigint REFERENCES public.users(id) ON DELETE SET NULL,
  title text NOT NULL,
  reason text NOT NULL,
  date_issued timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);
```

### 5. `announcements`
Guarda avisos y comunicaciones dirigidas a usuarios, orientadores o administradores.

```sql
CREATE TABLE public.announcements (
  id bigserial PRIMARY KEY,
  title text NOT NULL,
  description text NOT NULL,
  target_role text NOT NULL,
  created_at timestamptz DEFAULT now()
);
```

Valores típicos para `target_role`:
- `usuario`
- `orientador`
- `administrador`

---

## Relaciones principales

- `students.orientador_id` → `users.id`
- `reports.student_id` → `students.id`
- `reports.orientador_id` → `users.id`
- `justifications.student_id` → `students.id`
- `justifications.orientador_id` → `users.id`

---

## Ejemplos de datos iniciales

```sql
INSERT INTO public.users (email, role, name, phone, address) VALUES
('admin@escuela.com', 'administrador', 'Admin', '', ''),
('orientador@escuela.com', 'orientador', 'María García', '+52 55 1234 5678', 'Escuela Principal'),
('usuario@ejemplo.com', 'usuario', 'Juan Pérez', '+52 55 9876 5432', 'Calle Falsa 123');

INSERT INTO public.students (name, grade, status, orientador_id) VALUES
('Ana López', '3° Básico', 'Requiere apoyo', 2),
('Carlos Ramírez', '2° Medio', 'En seguimiento', 2),
('Sofia Martínez', '1° Medio', 'Caso cerrado', 2);

INSERT INTO public.announcements (title, description, target_role) VALUES
('Reunión de padres', 'Próxima reunión el 20 de abril', 'usuario'),
('Taller de orientación', 'Sesión informativa sobre carreras', 'usuario');

INSERT INTO public.justifications (student_id, orientador_id, title, reason, date_issued) VALUES
(1, 2, 'Justificante médico', 'Inasistencia por consulta médica.', now());
```

---

## Notas para Supabase

- Usa `timestamptz` para `created_at` y `date_issued`.
- Crea índices en los campos de búsqueda más usados si tu app crece:
  - `students.orientador_id`
  - `reports.student_id`
  - `reports.orientador_id`
  - `justifications.student_id`
  - `justifications.orientador_id`
- Si deseas usar autenticación de Supabase, puedes mapear el usuario actual a la tabla `users` vía `email`.

---

## Recomendación

En Supabase es conveniente mantener la lógica de permisos con `Row Level Security` (RLS) y roles si vas a restringir el acceso a reportes o justificantes.

Por ejemplo:
- Los orientadores solo ven sus estudiantes y sus reportes.
- El administrador puede ver todas las tablas.
- Los usuarios comunes pueden ver únicamente avisos y su propio perfil.
