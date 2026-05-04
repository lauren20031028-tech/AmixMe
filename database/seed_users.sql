-- Script para insertar usuarios de prueba en diferentes localidades de Bogotá
-- Ejecutar después de init.sql

-- Contraseña para todos: "password123" (bcrypt hash)
SET @password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

-- Usuarios en Suba (4.7479, -74.0832)
INSERT INTO users (email, password, name, age, bio, genero, localidad, direccion, latitude, longitude, created_at)
VALUES 
('maria.suba@test.com', @password_hash, 'María', 25, 'Amante del yoga y la fotografía 📸', 'Mujer', 'Suba', 'Suba Centro', 4.7479, -74.0832, NOW()),
('laura.suba@test.com', @password_hash, 'Laura', 28, 'Diseñadora gráfica y cinéfila 🎬', 'Mujer', 'Suba', 'Suba Rincón', 4.7520, -74.0890, NOW()),
('sofia.suba@test.com', @password_hash, 'Sofía', 23, 'Bailarina y amante de los gatos 🐱', 'Mujer', 'Suba', 'Suba Compartir', 4.7550, -74.0750, NOW());

-- Usuarios en Chapinero (4.6533, -74.0636)
INSERT INTO users (email, password, name, age, bio, genero, localidad, direccion, latitude, longitude, created_at)
VALUES 
('ana.chapinero@test.com', @password_hash, 'Ana', 27, 'Programadora y gamer 🎮', 'Mujer', 'Chapinero', 'Chapinero Alto', 4.6533, -74.0636, NOW()),
('camila.chapinero@test.com', @password_hash, 'Camila', 24, 'Artista y amante del K-Pop 🎵', 'Mujer', 'Chapinero', 'Chapinero Central', 4.6580, -74.0620, NOW()),
('valentina.chapinero@test.com', @password_hash, 'Valentina', 26, 'Chef y foodie apasionada 🍳', 'Mujer', 'Chapinero', 'Quinta Camacho', 4.6600, -74.0650, NOW());

-- Usuarios en Usaquén (4.7110, -74.0304)
INSERT INTO users (email, password, name, age, bio, genero, localidad, direccion, latitude, longitude, created_at)
VALUES 
('isabella.usaquen@test.com', @password_hash, 'Isabella', 29, 'Arquitecta y viajera 🌍', 'Mujer', 'Usaquén', 'Usaquén Centro', 4.7110, -74.0304, NOW()),
('daniela.usaquen@test.com', @password_hash, 'Daniela', 22, 'Estudiante de medicina y runner 🏃‍♀️', 'Mujer', 'Usaquén', 'Santa Bárbara', 4.7150, -74.0280, NOW()),
('paula.usaquen@test.com', @password_hash, 'Paula', 30, 'Psicóloga y lectora empedernida 📚', 'Mujer', 'Usaquén', 'Cedritos', 4.7200, -74.0350, NOW());

-- Usuarios en Kennedy (4.6280, -74.1470)
INSERT INTO users (email, password, name, age, bio, genero, localidad, direccion, latitude, longitude, created_at)
VALUES 
('andrea.kennedy@test.com', @password_hash, 'Andrea', 26, 'Profesora y amante de la naturaleza 🌿', 'Mujer', 'Kennedy', 'Kennedy Central', 4.6280, -74.1470, NOW()),
('natalia.kennedy@test.com', @password_hash, 'Natalia', 24, 'Ingeniera y ciclista urbana 🚴‍♀️', 'Mujer', 'Kennedy', 'Américas', 4.6300, -74.1500, NOW());

-- Usuarios en Engativá (4.7000, -74.1100)
INSERT INTO users (email, password, name, age, bio, genero, localidad, direccion, latitude, longitude, created_at)
VALUES 
('carolina.engativa@test.com', @password_hash, 'Carolina', 25, 'Fotógrafa y amante del café ☕', 'Mujer', 'Engativá', 'Engativá Centro', 4.7000, -74.1100, NOW()),
('juliana.engativa@test.com', @password_hash, 'Juliana', 28, 'Abogada y activista 💪', 'Mujer', 'Engativá', 'Minuto de Dios', 4.7050, -74.1150, NOW());

-- Asignar intereses aleatorios
INSERT INTO user_interests (user_id, interest_id)
SELECT u.id, i.id
FROM users u
CROSS JOIN interests i
WHERE RAND() < 0.3  -- 30% de probabilidad de tener cada interés
AND u.email LIKE '%@test.com';

-- Asignar géneros musicales aleatorios
INSERT INTO user_music_genres (user_id, music_genre_id)
SELECT u.id, m.id
FROM users u
CROSS JOIN music_genres m
WHERE RAND() < 0.25  -- 25% de probabilidad de tener cada género
AND u.email LIKE '%@test.com';

-- Verificar usuarios insertados
SELECT 
    name, 
    age, 
    localidad, 
    latitude, 
    longitude,
    (SELECT COUNT(*) FROM user_interests WHERE user_id = users.id) as num_interests,
    (SELECT COUNT(*) FROM user_music_genres WHERE user_id = users.id) as num_genres
FROM users 
WHERE email LIKE '%@test.com'
ORDER BY localidad, name;
