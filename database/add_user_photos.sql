-- Script para agregar soporte de múltiples fotos de usuario
-- Ejecutar después de init.sql

-- Crear tabla para fotos de usuario
CREATE TABLE IF NOT EXISTS user_photos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    photo_order INT NOT NULL DEFAULT 1,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_order (user_id, photo_order),
    INDEX idx_user_photos_user_id (user_id),
    INDEX idx_user_photos_primary (user_id, is_primary)
);

-- Migrar fotos existentes de profile_photo_url a la nueva tabla
INSERT INTO user_photos (user_id, photo_url, photo_order, is_primary)
SELECT id, profile_photo_url, 1, TRUE
FROM users 
WHERE profile_photo_url IS NOT NULL AND profile_photo_url != '';

-- Verificar migración
SELECT 
    u.name,
    u.profile_photo_url as old_photo,
    up.photo_url as new_photo,
    up.photo_order,
    up.is_primary
FROM users u
LEFT JOIN user_photos up ON u.id = up.user_id
WHERE u.profile_photo_url IS NOT NULL
ORDER BY u.id, up.photo_order;