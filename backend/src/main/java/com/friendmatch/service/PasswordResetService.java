package com.friendmatch.service;

import com.friendmatch.model.User;
import com.friendmatch.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // Almacén en memoria: token -> (email, expiración)
    // En producción esto debería persistirse en BD
    private final Map<String, TokenEntry> tokenStore = new ConcurrentHashMap<>();

    /**
     * Genera un token de recuperación para el email dado.
     * Devuelve el token (en producción se enviaría por correo).
     * Lanza IllegalArgumentException si el email no existe.
     */
    public String generarToken(String email) {
        userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("No existe una cuenta con ese correo"));

        // Invalidar tokens anteriores del mismo email
        tokenStore.entrySet().removeIf(e -> e.getValue().email.equals(email));

        String token = UUID.randomUUID().toString();
        tokenStore.put(token, new TokenEntry(email, LocalDateTime.now().plusHours(1)));
        return token;
    }

    /**
     * Restablece la contraseña usando el token.
     * Lanza IllegalArgumentException si el token es inválido o expiró.
     */
    public void restablecerContrasena(String token, String nuevaContrasena) {
        TokenEntry entry = tokenStore.get(token);

        if (entry == null || entry.expiracion.isBefore(LocalDateTime.now())) {
            tokenStore.remove(token);
            throw new IllegalArgumentException("El enlace de recuperación es inválido o ha expirado");
        }

        Optional<User> optUser = userRepository.findByEmail(entry.email);
        if (optUser.isEmpty()) {
            throw new IllegalArgumentException("Usuario no encontrado");
        }

        User user = optUser.get();
        user.setPasswordHash(passwordEncoder.encode(nuevaContrasena));
        userRepository.save(user);
        tokenStore.remove(token);
    }

    private record TokenEntry(String email, LocalDateTime expiracion) {}
}
