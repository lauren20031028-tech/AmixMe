SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS friendmatch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE friendmatch;

-- =============================================
-- TABLA USUARIOS
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    bio TEXT,
    genero VARCHAR(30),
    localidad VARCHAR(100),
    direccion VARCHAR(255),
    profile_photo_url VARCHAR(500),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    max_distance INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_photos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    photo_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- =============================================
-- PASATIEMPOS / INTERESES (con categoría)
-- =============================================
CREATE TABLE IF NOT EXISTS interests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    categoria VARCHAR(50) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_interests (
    user_id BIGINT NOT NULL,
    interest_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, interest_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (interest_id) REFERENCES interests(id) ON DELETE CASCADE
);

-- =============================================
-- GÉNEROS MUSICALES
-- =============================================
CREATE TABLE IF NOT EXISTS music_genres (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) UNIQUE NOT NULL,
    categoria VARCHAR(50) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_music_genres (
    user_id BIGINT NOT NULL,
    genre_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, genre_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES music_genres(id) ON DELETE CASCADE
);

-- =============================================
-- SWIPES, MATCHES, MENSAJES
-- =============================================
CREATE TABLE IF NOT EXISTS swipes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    swiper_id BIGINT NOT NULL,
    swiped_id BIGINT NOT NULL,
    is_like BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (swiper_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (swiped_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_swipe (swiper_id, swiped_id)
);

CREATE TABLE IF NOT EXISTS matches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user1_id BIGINT NOT NULL,
    user2_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_match (user1_id, user2_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    match_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Índices
CREATE INDEX idx_users_location ON users(latitude, longitude);
CREATE INDEX idx_users_localidad ON users(localidad);
CREATE INDEX idx_messages_match ON messages(match_id, created_at);
CREATE INDEX idx_swipes_swiper ON swipes(swiper_id);

-- =============================================
-- PASATIEMPOS POR CATEGORÍA
-- =============================================
INSERT IGNORE INTO interests (name, categoria) VALUES
-- Arte y Creatividad
('Pintura', 'Arte y Creatividad'),
('Dibujo', 'Arte y Creatividad'),
('Fotografía', 'Arte y Creatividad'),
('Manualidades', 'Arte y Creatividad'),
('Diseño gráfico', 'Arte y Creatividad'),
('Escultura', 'Arte y Creatividad'),
('Cerámica', 'Arte y Creatividad'),
-- Entretenimiento
('Ver películas', 'Entretenimiento'),
('Series y TV', 'Entretenimiento'),
('Videojuegos', 'Entretenimiento'),
('Anime', 'Entretenimiento'),
('Cómics', 'Entretenimiento'),
('Teatro', 'Entretenimiento'),
-- Deporte y Bienestar
('Yoga', 'Deporte y Bienestar'),
('Gimnasio', 'Deporte y Bienestar'),
('Ciclismo', 'Deporte y Bienestar'),
('Natación', 'Deporte y Bienestar'),
('Fútbol', 'Deporte y Bienestar'),
('Senderismo', 'Deporte y Bienestar'),
('Baile', 'Deporte y Bienestar'),
('Pilates', 'Deporte y Bienestar'),
-- Cultura y Conocimiento
('Lectura', 'Cultura y Conocimiento'),
('Idiomas', 'Cultura y Conocimiento'),
('Historia', 'Cultura y Conocimiento'),
('Ciencia', 'Cultura y Conocimiento'),
('Podcasts', 'Cultura y Conocimiento'),
('Filosofía', 'Cultura y Conocimiento'),
-- Gastronomía
('Cocinar', 'Gastronomía'),
('Repostería', 'Gastronomía'),
('Explorar restaurantes', 'Gastronomía'),
('Café de especialidad', 'Gastronomía'),
-- Viajes y Naturaleza
('Viajes', 'Viajes y Naturaleza'),
('Acampar', 'Viajes y Naturaleza'),
('Jardinería', 'Viajes y Naturaleza'),
('Observación de aves', 'Viajes y Naturaleza'),
-- Música
('Tocar guitarra', 'Música'),
('Canto', 'Música'),
('DJ', 'Música'),
('Producción musical', 'Música'),
('Ir a conciertos', 'Música'),
-- Tecnología
('Programación', 'Tecnología'),
('Inteligencia artificial', 'Tecnología'),
('Robótica', 'Tecnología'),
('Gadgets', 'Tecnología');

-- =============================================
-- GÉNEROS MUSICALES POR CATEGORÍA
-- =============================================
INSERT IGNORE INTO music_genres (name, categoria) VALUES
-- Pop
('Pop latino', 'Pop'),
('Pop en inglés', 'Pop'),
('K-Pop', 'Pop'),
('Pop alternativo', 'Pop'),
-- Urbano
('Reggaetón', 'Urbano'),
('Trap', 'Urbano'),
('Afrobeats', 'Urbano'),
('Dembow', 'Urbano'),
('Dancehall', 'Urbano'),
-- Rock
('Rock clásico', 'Rock'),
('Rock alternativo', 'Rock'),
('Metal', 'Rock'),
('Punk', 'Rock'),
('Indie rock', 'Rock'),
-- Electrónica
('House', 'Electrónica'),
('Techno', 'Electrónica'),
('EDM', 'Electrónica'),
('Lo-fi', 'Electrónica'),
('Ambient', 'Electrónica'),
-- Clásica y Jazz
('Música clásica', 'Clásica y Jazz'),
('Jazz', 'Clásica y Jazz'),
('Blues', 'Clásica y Jazz'),
('Soul', 'Clásica y Jazz'),
-- Colombiana
('Vallenato', 'Colombiana'),
('Cumbia', 'Colombiana'),
('Salsa', 'Colombiana'),
('Mapalé', 'Colombiana'),
('Champeta', 'Colombiana'),
-- Hip-Hop
('Hip-hop', 'Hip-Hop'),
('R&B', 'Hip-Hop'),
('Neo soul', 'Hip-Hop');

-- =============================================
-- USUARIAS DE PRUEBA (contraseña: test1234)
-- Contraseña para todas: test1234
-- Hash generado con BCrypt strength 10
-- =============================================
-- USUARIOS EN SUBA (3 usuarios con intereses comunes)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(1, 'sofia@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Sofía', 25, 'Me encanta el café, los libros y explorar la ciudad 📚☕',
 'Mujer', 'Suba', 'Calle 145 con Carrera 91',
 4.7417, -74.0934, 15, true),
(2, 'valentina@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Valentina', 28, 'Fotógrafa amateur, amante del yoga y los viajes 📷🧘‍♀️',
 'Mujer', 'Suba', 'Calle 150 con Carrera 95',
 4.7420, -74.0940, 15, true),
(3, 'camila@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Camila', 23, 'Estudiante de diseño, amo el arte urbano y los conciertos 🎨🎶',
 'No binario', 'Suba', 'Calle 155 con Carrera 100',
 4.7425, -74.0945, 15, true),
-- USUARIOS EN CHAPINERO (2 usuarios con diferentes intereses)
(4, 'isabella@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Isabella', 26, 'Apasionada por la cocina, el senderismo y los podcasts 🍳🏔️',
 'Mujer', 'Chapinero', 'Calle 67 con Carrera 7',
 4.6486, -74.0628, 15, true),
(5, 'mariana@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Mariana', 30, 'Programadora, gamer y amante del K-Pop y el anime 💻🎮',
 'Mujer trans', 'Chapinero', 'Calle 70 con Carrera 10',
 4.6490, -74.0635, 15, true);

-- Intereses - SUBA (3 usuarios con intereses comunes)
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 1, id FROM interests WHERE name IN ('Lectura','Fotografía','Yoga','Viajes');

INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 2, id FROM interests WHERE name IN ('Fotografía','Yoga','Viajes','Baile');

INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 3, id FROM interests WHERE name IN ('Lectura','Fotografía','Baile','Viajes');

-- Intereses - CHAPINERO (2 usuarios con diferentes intereses)
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 4, id FROM interests WHERE name IN ('Cocinar','Repostería','Senderismo','Podcasts');

INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 5, id FROM interests WHERE name IN ('Programación','Videojuegos','Anime','Inteligencia artificial');

-- Géneros musicales - SUBA (3 usuarios con géneros comunes)
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 1, id FROM music_genres WHERE name IN ('Pop latino','Jazz','Lo-fi','Salsa');

INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 2, id FROM music_genres WHERE name IN ('Reggaetón','Salsa','Pop alternativo','Vallenato');

INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 3, id FROM music_genres WHERE name IN ('Indie rock','Pop alternativo','Rock alternativo','Lo-fi');

-- Géneros musicales - CHAPINERO (2 usuarios con géneros diferentes)
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 4, id FROM music_genres WHERE name IN ('Jazz','Blues','Soul','Música clásica');

INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 5, id FROM music_genres WHERE name IN ('K-Pop','EDM','Hip-hop','Techno');


-- =============================================
-- SWIPES Y MATCHES DE PRUEBA
-- =============================================
-- Swipes mutuos que crean matches
-- Usuario 1 (sofia@test.com) da like a Usuario 2 (valentina@test.com)
INSERT IGNORE INTO swipes (swiper_id, swiped_id, is_like, created_at) VALUES
(1, 2, true, NOW() - INTERVAL 2 DAY);

-- Usuario 2 (valentina@test.com) da like a Usuario 1 (sofia@test.com) - MATCH!
INSERT IGNORE INTO swipes (swiper_id, swiped_id, is_like, created_at) VALUES
(2, 1, true, NOW() - INTERVAL 1 DAY);

-- Usuario 1 (sofia@test.com) da like a Usuario 3 (camila@test.com)
INSERT IGNORE INTO swipes (swiper_id, swiped_id, is_like, created_at) VALUES
(1, 3, true, NOW() - INTERVAL 1 DAY);

-- Usuario 3 (camila@test.com) da like a Usuario 1 (sofia@test.com) - MATCH!
INSERT IGNORE INTO swipes (swiper_id, swiped_id, is_like, created_at) VALUES
(3, 1, true, NOW() - INTERVAL 12 HOUR);

-- Usuario 4 (isabella@test.com) da like a Usuario 1 (sofia@test.com) - PENDIENTE
INSERT IGNORE INTO swipes (swiper_id, swiped_id, is_like, created_at) VALUES
(4, 1, true, NOW() - INTERVAL 6 HOUR);

-- Usuario 1 (sofia@test.com) da like a Usuario 5 (mariana@test.com) - PENDIENTE
INSERT IGNORE INTO swipes (swiper_id, swiped_id, is_like, created_at) VALUES
(1, 5, true, NOW() - INTERVAL 3 HOUR);

-- =============================================
-- MATCHES AUTOMÁTICOS (cuando hay like mutuo)
-- =============================================
-- Match entre Usuario 1 y Usuario 2
INSERT IGNORE INTO matches (user1_id, user2_id, created_at) VALUES
(1, 2, NOW() - INTERVAL 1 DAY);

-- Match entre Usuario 1 y Usuario 3
INSERT IGNORE INTO matches (user1_id, user2_id, created_at) VALUES
(1, 3, NOW() - INTERVAL 12 HOUR);

-- =============================================
-- MENSAJES DE PRUEBA
-- =============================================
-- Conversación entre Usuario 1 (Sofía) y Usuario 2 (Valentina)
INSERT IGNORE INTO messages (match_id, sender_id, message_text, created_at) VALUES
(1, 2, '¡Hola Sofía! Me encanta que tengamos tantos intereses en común 😊', NOW() - INTERVAL 20 HOUR),
(1, 1, 'Hola Valentina! Sí, vi que también te gusta la fotografía 📷', NOW() - INTERVAL 19 HOUR),
(1, 2, 'Exacto! ¿Has ido a algún lugar interesante a tomar fotos últimamente?', NOW() - INTERVAL 18 HOUR),
(1, 1, 'Sí, fui al centro histórico el fin pasado. Las fotos quedaron increíbles ✨', NOW() - INTERVAL 17 HOUR),
(1, 2, '¡Qué genial! Me encantaría ver esas fotos algún día', NOW() - INTERVAL 2 HOUR);

-- Conversación entre Usuario 1 (Sofía) y Usuario 3 (Camila)
INSERT IGNORE INTO messages (match_id, sender_id, message_text, created_at) VALUES
(2, 1, '¡Hola Camila! Vi que estudias diseño, ¡qué interesante! 🎨', NOW() - INTERVAL 10 HOUR),
(2, 3, 'Hola Sofía! Sí, me encanta el diseño gráfico. ¿Tú también eres creativa?', NOW() - INTERVAL 9 HOUR),
(2, 1, 'Me gusta leer y la fotografía, pero admiro mucho a las personas artísticas como tú', NOW() - INTERVAL 8 HOUR),
(2, 3, 'Ay qué linda! Deberíamos ir juntas a alguna exposición de arte 🖼️', NOW() - INTERVAL 1 HOUR);
-- =============================================
-- USUARIOS ADICIONALES PARA USAQUÉN
-- =============================================
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(6, 'lucia@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Lucía', 24, 'Amante del arte, la música y los buenos libros 🎨📚🎵',
 'Mujer', 'Usaquén', 'Calle 116 con Carrera 15',
 4.7010, -74.0320, 15, true),
(7, 'andrea@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Andrea', 27, 'Fotógrafa profesional y viajera empedernida ✈️📸',
 'Mujer', 'Usaquén', 'Calle 120 con Carrera 11',
 4.7015, -74.0315, 15, true),
(8, 'daniela@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Daniela', 26, 'Chef en formación, yoga lover y amante de la naturaleza 🧘‍♀️🌿',
 'Mujer', 'Usaquén', 'Calle 122 con Carrera 13',
 4.7020, -74.0318, 15, true);

-- Intereses para usuarios de Usaquén
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 6, id FROM interests WHERE name IN ('Pintura','Lectura','Ir a conciertos','Café de especialidad');

INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 7, id FROM interests WHERE name IN ('Fotografía','Viajes','Senderismo','Arte urbano');

INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 8, id FROM interests WHERE name IN ('Cocinar','Yoga','Jardinería','Explorar restaurantes');

-- Géneros musicales para usuarios de Usaquén
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 6, id FROM music_genres WHERE name IN ('Indie rock','Jazz','Pop alternativo','Vallenato');

INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 7, id FROM music_genres WHERE name IN ('Pop latino','Rock alternativo','Salsa','Lo-fi');

INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 8, id FROM music_genres WHERE name IN ('Jazz','Blues','Música clásica','Cumbia');
-- =============================================
-- USUARIOS PARA OTRAS LOCALIDADES
-- =============================================
-- Teusaquillo
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(9, 'paula@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Paula', 25, 'Diseñadora UX/UI, gamer y amante del K-Pop 🎮💜',
 'Mujer', 'Teusaquillo', 'Av. El Dorado con Carrera 45',
 4.6350, -74.0880, 15, true);

-- Engativá
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(10, 'carolina@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Carolina', 29, 'Psicóloga, bailarina y amante de los podcasts 💃🎧',
 'Mujer', 'Engativá', 'Calle 80 con Carrera 100',
 4.6700, -74.1200, 15, true);

-- Intereses adicionales
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 9, id FROM interests WHERE name IN ('Diseño gráfico','Videojuegos','Anime','Programación');

INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 10, id FROM interests WHERE name IN ('Baile','Podcasts','Yoga','Lectura');

-- Géneros musicales adicionales
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 9, id FROM music_genres WHERE name IN ('K-Pop','EDM','Pop alternativo','Hip-hop');

INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 10, id FROM music_genres WHERE name IN ('Salsa','Reggaetón','Pop latino','R&B');


-- =============================================
-- USUARIOS PARA LOCALIDADES FALTANTES
-- Contraseña para todos: test1234
-- =============================================

-- KENNEDY (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(11, 'natalia@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Natalia', 24, 'Amante de los videojuegos y el anime 🎮🎌',
 'Mujer', 'Kennedy', 'Carrera 72D con Calle 9',
 4.6280, -74.1500, 15, true),
(12, 'vanesa@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Vanesa', 27, 'Maestra de primaria, me encantan los libros y el café 📚☕',
 'Mujer', 'Kennedy', 'Calle 8BIS con Carrera 70',
 4.6290, -74.1510, 15, true),
(13, 'stephanie@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Stephanie', 22, 'Estudiante de medicina, bailarina de salsa 💃🏥',
 'Mujer', 'Kennedy', 'Calle 12 con Carrera 68',
 4.6270, -74.1490, 15, true);

-- CIUDAD BOLÍVAR (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(14, 'yuliana@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Yuliana', 26, 'Trabajadora social, me apasiona ayudar a los demás 💜',
 'Mujer', 'Ciudad Bolívar', 'Calle 62B Sur con Carrera 0',
 4.5100, -74.1600, 15, true),
(15, 'karen@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Karen', 23, 'Estudiante de arte, amo pintar y dibujar 🎨✏️',
 'Mujer', 'Ciudad Bolívar', 'Calle 58 Sur con Carrera 5',
 4.5120, -74.1580, 15, true),
(16, 'laura@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Laura', 28, 'Ingeniera ambiental, amante de la naturaleza y el senderismo 🌿🥾',
 'Mujer', 'Ciudad Bolívar', 'Calle 65 Sur con Carrera 2',
 4.5080, -74.1620, 15, true);

-- BOSA (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(17, 'diana@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Diana', 25, 'Contadora, me encanta la repostería y los viajes 🧁✈️',
 'Mujer', 'Bosa', 'Carrera 80 con Calle 60 Sur',
 4.6200, -74.1900, 15, true),
(18, 'jessica@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Jessica', 29, 'Abogada, apasionada por la justicia social y los podcasts ⚖️🎧',
 'Mujer', 'Bosa', 'Calle 62 Sur con Carrera 78',
 4.6210, -74.1910, 15, true),
(19, 'melissa@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Melissa', 24, 'Diseñadora de modas, amo la creatividad y el arte 🧵👗',
 'Mujer', 'Bosa', 'Calle 58 Sur con Carrera 82',
 4.6190, -74.1890, 15, true);

-- SAN CRISTÓBAL (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(20, 'angie@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Angie', 26, 'Fisioterapeuta, amante del deporte y la vida saludable 💪🏃‍♀️',
 'Mujer', 'San Cristóbal', 'Calle 5 Sur con Carrera 20',
 4.5600, -74.0900, 15, true),
(21, 'catalina@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Catalina', 23, 'Estudiante de música, toco el piano y me encanta el jazz 🎹🎷',
 'Mujer', 'San Cristóbal', 'Calle 8 Sur con Carrera 18',
 4.5620, -74.0880, 15, true),
(22, 'sara@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Sara', 27, 'Periodista, me apasionan las historias y los documentales 📰🎬',
 'Mujer', 'San Cristóbal', 'Calle 3 Sur con Carrera 22',
 4.5580, -74.0920, 15, true);

-- RAFAEL URIBE URIBE (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(23, 'lina@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Lina', 25, 'Arquitecta, me encanta el diseño urbano y la fotografía 🏗️📷',
 'Mujer', 'Rafael Uribe Uribe', 'Calle 30 Sur con Carrera 15',
 4.5700, -74.1100, 15, true),
(24, 'monica@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Mónica', 28, 'Chef profesional, amo la gastronomía colombiana 🍲🇨🇴',
 'Mujer', 'Rafael Uribe Uribe', 'Calle 28 Sur con Carrera 17',
 4.5720, -74.1080, 15, true),
(25, 'paola@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Paola', 24, 'Psicóloga, me encantan los libros de autoayuda y el yoga 📚🧘‍♀️',
 'Mujer', 'Rafael Uribe Uribe', 'Calle 32 Sur con Carrera 13',
 4.5680, -74.1120, 15, true);

-- PUENTE ARANDA (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(26, 'victoria@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Victoria', 26, 'Publicista, creativa y amante del diseño gráfico 🎨💡',
 'Mujer', 'Puente Aranda', 'Calle 16 con Carrera 30',
 4.6100, -74.1000, 15, true),
(27, 'camila.ruiz@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Camila Ruiz', 29, 'Ingeniera de sistemas, gamer y fan del K-Pop 💻🎮',
 'Mujer', 'Puente Aranda', 'Calle 18 con Carrera 28',
 4.6120, -74.0980, 15, true),
(28, 'tatiana@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Tatiana', 23, 'Estudiante de cine, amo las películas y los festivales 🎬🍿',
 'Mujer', 'Puente Aranda', 'Calle 14 con Carrera 32',
 4.6080, -74.1020, 15, true);

-- LOS MÁRTIRES (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(29, 'andrea.gomez@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Andrea Gómez', 27, 'Enfermera, me apasiona cuidar a los demás 💉❤️',
 'Mujer', 'Los Mártires', 'Calle 10 con Carrera 20',
 4.6000, -74.0800, 15, true),
(30, 'luz@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Luz', 25, 'Comunicadora social, amo el teatro y la actuación 🎭🎬',
 'Mujer', 'Los Mártires', 'Calle 8 con Carrera 22',
 4.6020, -74.0780, 15, true),
(31, 'maria@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'María', 30, 'Profesora de inglés, me encantan los idiomas y los viajes 🌍✈️',
 'Mujer', 'Los Mártires', 'Calle 12 con Carrera 18',
 4.5980, -74.0820, 15, true);

-- ANTONIO NARIÑO (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(32, 'juliana@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Juliana', 24, 'Diseñadora industrial, amo crear cosas nuevas 🎨✨',
 'Mujer', 'Antonio Nariño', 'Calle 15 Sur con Carrera 10',
 4.5800, -74.1100, 15, true),
(33, 'daniela.martinez@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Daniela Martínez', 28, 'Médica, me encanta la ciencia y ayudar a los demás 👩‍⚕️💊',
 'Mujer', 'Antonio Nariño', 'Calle 17 Sur con Carrera 8',
 4.5820, -74.1080, 15, true),
(34, 'veronica@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Verónica', 26, 'Abogada, amante de la lectura y el café ⚖️☕',
 'Mujer', 'Antonio Nariño', 'Calle 13 Sur con Carrera 12',
 4.5780, -74.1120, 15, true);

-- SANTA FE (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(35, 'gabriela@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Gabriela', 25, 'Artista plástica, amo los museos y las exposiciones 🖼️🎨',
 'Mujer', 'Santa Fe', 'Carrera 4 con Calle 20',
 4.5950, -74.0700, 15, true),
(36, 'alejandra@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Alejandra', 29, 'Historiadora, me apasiona la historia de Bogotá 📚🏛️',
 'Mujer', 'Santa Fe', 'Calle 22 con Carrera 6',
 4.5970, -74.0680, 15, true),
(37, 'isabel@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Isabel', 27, 'Antropóloga, amo las culturas y los viajes 🌎✈️',
 'Mujer', 'Santa Fe', 'Calle 18 con Carrera 3',
 4.5930, -74.0720, 15, true);

-- LA CANDELARIA (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(38, 'fernanda@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Fernanda', 26, 'Escritora, me encantan los libros y los cafés literarios ✍️📚',
 'Mujer', 'La Candelaria', 'Calle 11 con Carrera 4',
 4.5980, -74.0680, 15, true),
(39, 'adriana@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Adriana', 24, 'Estudiante de historia del arte, amo los museos 🖼️🏛️',
 'Mujer', 'La Candelaria', 'Calle 9 con Carrera 6',
 4.6000, -74.0660, 15, true),
(40, 'patricia@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Patricia', 28, 'Fotógrafa de bodas, amo capturar momentos especiales 📸💕',
 'Mujer', 'La Candelaria', 'Calle 12 con Carrera 2',
 4.5960, -74.0700, 15, true);

-- TUNJUELITO (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(41, 'nancy@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Nancy', 25, 'Administradora de empresas, me encanta el emprendimiento 💼💡',
 'Mujer', 'Tunjuelito', 'Calle 45 Sur con Carrera 15',
 4.5400, -74.1300, 15, true),
(42, 'claudia@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Claudia', 27, 'Diseñadora gráfica, amo la creatividad y el arte digital 🎨💻',
 'Mujer', 'Tunjuelito', 'Calle 48 Sur con Carrera 12',
 4.5420, -74.1280, 15, true),
(43, 'sandra@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Sandra', 23, 'Estudiante de marketing, me encantan las redes sociales 📱💜',
 'Mujer', 'Tunjuelito', 'Calle 42 Sur con Carrera 18',
 4.5380, -74.1320, 15, true);

-- BARRIOS UNIDOS (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(44, 'elena@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Elena', 26, 'Ingeniera química, amante de la ciencia y los experimentos 🔬🧪',
 'Mujer', 'Barrios Unidos', 'Calle 66 con Carrera 28',
 4.6600, -74.0800, 15, true),
(45, 'raquel@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Raquel', 29, 'Profesora de yoga, me encanta la meditación y el bienestar 🧘‍♀️✨',
 'Mujer', 'Barrios Unidos', 'Calle 68 con Carrera 30',
 4.6620, -74.0780, 15, true),
(46, 'lorena@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Lorena', 24, 'Estudiante de nutrición, me encanta la comida saludable 🥗💪',
 'Mujer', 'Barrios Unidos', 'Calle 64 con Carrera 26',
 4.6580, -74.0820, 15, true);

-- FONTIBÓN (3 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(47, 'carmen@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Carmen', 27, 'Piloto, me encanta volar y conocer nuevos lugares ✈️🌍',
 'Mujer', 'Fontibón', 'Calle 20 con Carrera 100',
 4.6500, -74.1400, 15, true),
(48, 'rosa@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Rosa', 25, 'Veterinaria, amo los animales y la naturaleza 🐾🌿',
 'Mujer', 'Fontibón', 'Calle 22 con Carrera 98',
 4.6520, -74.1380, 15, true),
(49, 'silvia@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Silvia', 28, 'Arquitecta, me encanta el diseño sostenible 🏡🌱',
 'Mujer', 'Fontibón', 'Calle 18 con Carrera 102',
 4.6480, -74.1420, 15, true);

-- CANDELARIA (localidad rural) (2 usuarios)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(50, 'martha@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Martha', 30, 'Agricultora orgánica, amo la naturaleza y la vida rural 🌾🌻',
 'Mujer', 'Candelaria', 'Vereda El Charquito',
 4.4000, -74.0500, 20, true),
(51, 'beatriz@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Beatriz', 28, 'Maestra rural, me encanta enseñar y aprender 📚🏫',
 'Mujer', 'Candelaria', 'Vereda El Hato',
 4.4050, -74.0550, 20, true);

-- SUMAPAZ (2 usuarios - zona rural)
INSERT IGNORE INTO users (id, email, password_hash, name, age, bio, genero, localidad, direccion, latitude, longitude, max_distance, is_active) VALUES
(52, 'olga@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Olga', 32, 'Guardabosques, protectora del páramo y la naturaleza 🌲🦌',
 'Mujer', 'Sumapaz', 'Corregimiento de Sumapaz',
 4.2000, -74.1000, 25, true),
(53, 'teresa@test.com',
 '$2a$10$Q4i9ed1i0W.4GS4dqiNAwecDIZ5nm3jX4SSKnD2Q0X0CBHiVEyHi6',
 'Teresa', 29, 'Bióloga, investigadora del páramo y amante de la ciencia 🔬🌿',
 'Mujer', 'Sumapaz', 'Vereda Nazareth',
 4.2100, -74.0950, 25, true);

-- =============================================
-- INTERESES PARA USUARIOS DE NUEVAS LOCALIDADES
-- =============================================

-- Intereses - KENNEDY
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 11, id FROM interests WHERE name IN ('Videojuegos','Anime','Programación','Tecnología');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 12, id FROM interests WHERE name IN ('Lectura','Café de especialidad','Yoga','Viajes');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 13, id FROM interests WHERE name IN ('Baile','Yoga','Viajes','Fotografía');

-- Intereses - CIUDAD BOLÍVAR
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 14, id FROM interests WHERE name IN ('Voluntariado','Lectura','Podcasts','Yoga');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 15, id FROM interests WHERE name IN ('Pintura','Dibujo','Fotografía','Arte urbano');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 16, id FROM interests WHERE name IN ('Senderismo','Jardinería','Viajes','Naturaleza');

-- Intereses - BOSA
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 17, id FROM interests WHERE name IN ('Repostería','Viajes','Cocinar','Fotografía');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 18, id FROM interests WHERE name IN ('Podcasts','Lectura','Derecho','Justicia social');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 19, id FROM interests WHERE name IN ('Diseño gráfico','Pintura','Moda','Arte urbano');

-- Intereses - SAN CRISTÓBAL
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 20, id FROM interests WHERE name IN ('Gimnasio','Yoga','Natación','Deportes');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 21, id FROM interests WHERE name IN ('Música','Piano','Jazz','Ir a conciertos');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 22, id FROM interests WHERE name IN ('Escritura','Periodismo','Documentales','Podcasts');

-- Intereses - RAFAEL URIBE URIBE
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 23, id FROM interests WHERE name IN ('Arquitectura','Fotografía','Diseño gráfico','Arte urbano');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 24, id FROM interests WHERE name IN ('Cocinar','Gastronomía','Viajes','Explorar restaurantes');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 25, id FROM interests WHERE name IN ('Lectura','Yoga','Psicología','Meditación');

-- Intereses - PUENTE ARANDA
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 26, id FROM interests WHERE name IN ('Diseño gráfico','Publicidad','Arte','Creatividad');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 27, id FROM interests WHERE name IN ('Programación','Videojuegos','Tecnología','Anime');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 28, id FROM interests WHERE name IN ('Cine','Series y TV','Teatro','Festivales');

-- Intereses - LOS MÁRTIRES
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 29, id FROM interests WHERE name IN ('Medicina','Voluntariado','Yoga','Lectura');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 30, id FROM interests WHERE name IN ('Teatro','Actuación','Cine','Arte');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 31, id FROM interests WHERE name IN ('Idiomas','Viajes','Enseñanza','Lectura');

-- Intereses - ANTONIO NARIÑO
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 32, id FROM interests WHERE name IN ('Diseño','Arte','Creatividad','Manualidades');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 33, id FROM interests WHERE name IN ('Medicina','Ciencia','Lectura','Yoga');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 34, id FROM interests WHERE name IN ('Lectura','Café de especialidad','Derecho','Podcasts');

-- Intereses - SANTA FE
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 35, id FROM interests WHERE name IN ('Pintura','Fotografía','Museos','Arte');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 36, id FROM interests WHERE name IN ('Historia','Museos','Lectura','Arquitectura');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 37, id FROM interests WHERE name IN ('Antropología','Viajes','Culturas','Fotografía');

-- Intereses - LA CANDELARIA
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 38, id FROM interests WHERE name IN ('Escritura','Lectura','Café de especialidad','Poesía');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 39, id FROM interests WHERE name IN ('Historia del arte','Museos','Pintura','Arte');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 40, id FROM interests WHERE name IN ('Fotografía','Viajes','Bodas','Eventos');

-- Intereses - TUNJUELITO
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 41, id FROM interests WHERE name IN ('Emprendimiento','Negocios','Lectura','Tecnología');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 42, id FROM interests WHERE name IN ('Diseño gráfico','Arte digital','Creatividad','Tecnología');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 43, id FROM interests WHERE name IN ('Marketing','Redes sociales','Creatividad','Tecnología');

-- Intereses - BARRIOS UNIDOS
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 44, id FROM interests WHERE name IN ('Ciencia','Experimentos','Tecnología','Lectura');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 45, id FROM interests WHERE name IN ('Yoga','Meditación','Bienestar','Pilates');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 46, id FROM interests WHERE name IN ('Nutrición','Cocinar','Deportes','Bienestar');

-- Intereses - FONTIBÓN
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 47, id FROM interests WHERE name IN ('Aviación','Viajes','Fotografía','Aventura');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 48, id FROM interests WHERE name IN ('Animales','Naturaleza','Jardinería','Voluntariado');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 49, id FROM interests WHERE name IN ('Arquitectura','Diseño','Sostenibilidad','Naturaleza');

-- Intereses - CANDELARIA (rural)
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 50, id FROM interests WHERE name IN ('Agricultura','Jardinería','Naturaleza','Cocinar');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 51, id FROM interests WHERE name IN ('Enseñanza','Lectura','Naturaleza','Voluntariado');

-- Intereses - SUMAPAZ
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 52, id FROM interests WHERE name IN ('Naturaleza','Senderismo','Conservación','Jardinería');
INSERT IGNORE INTO user_interests (user_id, interest_id)
SELECT 53, id FROM interests WHERE name IN ('Ciencia','Biología','Naturaleza','Investigación');

-- =============================================
-- GÉNEROS MUSICALES PARA USUARIOS DE NUEVAS LOCALIDADES
-- =============================================

-- Géneros musicales - KENNEDY
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 11, id FROM music_genres WHERE name IN ('K-Pop','EDM','Pop latino','Hip-hop');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 12, id FROM music_genres WHERE name IN ('Jazz','Lo-fi{}
','Música clásica','Pop alternativo');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 13, id FROM music_genres WHERE name IN ('Salsa','Reggaetón','Pop latino','Vallenato');

-- Géneros musicales - CIUDAD BOLÍVAR
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 14, id FROM music_genres WHERE name IN ('Pop latino','Vallenato','Salsa','Cumbia');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 15, id FROM music_genres WHERE name IN ('Indie rock','Pop alternativo','Lo-fi','Jazz');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 16, id FROM music_genres WHERE name IN ('Rock alternativo','Indie rock','Pop alternativo','Ambient');

-- Géneros musicales - BOSA
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 17, id FROM music_genres WHERE name IN ('Pop latino','Vallenato','Salsa','Reggaetón');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 18, id FROM music_genres WHERE name IN ('Podcasts','Jazz','Blues','Soul');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 19, id FROM music_genres WHERE name IN ('Pop alternativo','Indie rock','EDM','K-Pop');

-- Géneros musicales - SAN CRISTÓBAL
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 20, id FROM music_genres WHERE name IN ('Reggaetón','Pop latino','EDM','Dembow');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 21, id FROM music_genres WHERE name IN ('Jazz','Música clásica','Blues','Soul');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 22, id FROM music_genres WHERE name IN ('Pop alternativo','Indie rock','Lo-fi','Podcasts');

-- Géneros musicales - RAFAEL URIBE URIBE
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 23, id FROM music_genres WHERE name IN ('Indie rock','Pop alternativo','Lo-fi','Jazz');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 24, id FROM music_genres WHERE name IN ('Salsa','Cumbia','Vallenato','Jazz');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 25, id FROM music_genres WHERE name IN ('Lo-fi','Música clásica','Jazz','Ambient');

-- Géneros musicales - PUENTE ARANDA
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 26, id FROM music_genres WHERE name IN ('Pop alternativo','Indie rock','EDM','House');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 27, id FROM music_genres WHERE name IN ('K-Pop','EDM','Hip-hop','Techno');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 28, id FROM music_genres WHERE name IN ('Indie rock','Pop alternativo','Lo-fi','Rock alternativo');

-- Géneros musicales - LOS MÁRTIRES
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 29, id FROM music_genres WHERE name IN ('Pop latino','Salsa','Vallenato','Reggaetón');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 30, id FROM music_genres WHERE name IN ('Música clásica','Jazz','Blues','Soul');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 31, id FROM music_genres WHERE name IN ('Pop latino','Pop en inglés','Jazz','Lo-fi');

-- Géneros musicales - ANTONIO NARIÑO
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 32, id FROM music_genres WHERE name IN ('Indie rock','Pop alternativo','EDM','House');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 33, id FROM music_genres WHERE name IN ('Pop latino','Salsa','Vallenato','Jazz');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 34, id FROM music_genres WHERE name IN ('Jazz','Blues','Música clásica','Lo-fi');

-- Géneros musicales - SANTA FE
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 35, id FROM music_genres WHERE name IN ('Jazz','Música clásica','Indie rock','Pop alternativo');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 36, id FROM music_genres WHERE name IN ('Música clásica','Jazz','Blues','Soul');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 37, id FROM music_genres WHERE name IN ('World music','Jazz','Salsa','Cumbia');

-- Géneros musicales - LA CANDELARIA
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 38, id FROM music_genres WHERE name IN ('Jazz','Lo-fi','Música clásica','Indie rock');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 39, id FROM music_genres WHERE name IN ('Música clásica','Jazz','Blues','Soul');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 40, id FROM music_genres WHERE name IN ('Pop latino','Salsa','Vallenato','Pop en inglés');

-- Géneros musicales - TUNJUELITO
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 41, id FROM music_genres WHERE name IN ('Pop latino','Reggaetón','EDM','Hip-hop');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 42, id FROM music_genres WHERE name IN ('EDM','House','Techno','Lo-fi');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 43, id FROM music_genres WHERE name IN ('K-Pop','Pop latino','EDM','Hip-hop');

-- Géneros musicales - BARRIOS UNIDOS
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 44, id FROM music_genres WHERE name IN ('Lo-fi','Ambient','Música clásica','Jazz');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 45, id FROM music_genres WHERE name IN ('Ambient','Lo-fi','Música clásica','Soul');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 46, id FROM music_genres WHERE name IN ('Pop latino','Reggaetón','Salsa','Vallenato');

-- Géneros musicales - FONTIBÓN
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 47, id FROM music_genres WHERE name IN ('Pop en inglés','EDM','House','Techno');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 48, id FROM music_genres WHERE name IN ('Pop latino','Salsa','Vallenato','Cumbia');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 49, id FROM music_genres WHERE name IN ('Indie rock','Pop alternativo','Lo-fi','Ambient');

-- Géneros musicales - CANDELARIA (rural)
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 50, id FROM music_genres WHERE name IN ('Vallenato','Cumbia','Salsa','Música colombiana');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 51, id FROM music_genres WHERE name IN ('Vallenato','Cumbia','Pop latino','Salsa');

-- Géneros musicales - SUMAPAZ
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 52, id FROM music_genres WHERE name IN ('Música clásica','Ambient','Folk','Música colombiana');
INSERT IGNORE INTO user_music_genres (user_id, genre_id)
SELECT 53, id FROM music_genres WHERE name IN ('Ambient','Música clásica','Jazz','Lo-fi');
