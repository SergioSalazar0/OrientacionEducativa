-- Crear tabla de auditoría para logs del sistema
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete', 'login', 'logout', etc.
    entity_type VARCHAR(50) NOT NULL, -- 'user', 'student', 'report', 'justification', 'announcement', 'appointment'
    entity_id INTEGER, -- ID del registro afectado
    details TEXT NOT NULL, -- Descripción detallada de la acción
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Desactivar RLS para esta tabla (para que todos puedan ver logs)
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);

-- Comentarios para documentación
COMMENT ON TABLE audit_logs IS 'Tabla de auditoría que registra todas las acciones del sistema';
COMMENT ON COLUMN audit_logs.user_id IS 'Usuario que realizó la acción (NULL para acciones del sistema)';
COMMENT ON COLUMN audit_logs.action IS 'Tipo de acción realizada';
COMMENT ON COLUMN audit_logs.entity_type IS 'Tipo de entidad afectada';
COMMENT ON COLUMN audit_logs.entity_id IS 'ID del registro específico afectado';
COMMENT ON COLUMN audit_logs.details IS 'Descripción detallada de la acción realizada';
COMMENT ON COLUMN audit_logs.created_at IS 'Fecha y hora de la acción';