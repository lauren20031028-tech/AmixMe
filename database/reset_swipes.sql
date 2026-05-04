-- Script para limpiar swipes y matches
-- Esto permite que los usuarios vuelvan a aparecer en la pantalla de descubrimiento

USE friendmatch;

-- Eliminar todos los swipes
DELETE FROM swipes;

-- Eliminar todos los matches
DELETE FROM matches;

-- Eliminar todos los mensajes
DELETE FROM messages;

-- Verificar que se eliminaron correctamente
SELECT 'Swipes eliminados:' as mensaje, COUNT(*) as total FROM swipes;
SELECT 'Matches eliminados:' as mensaje, COUNT(*) as total FROM matches;
SELECT 'Mensajes eliminados:' as mensaje, COUNT(*) as total FROM messages;

-- Mostrar usuarios disponibles
SELECT id, name, email, localidad FROM users WHERE is_active = true;
