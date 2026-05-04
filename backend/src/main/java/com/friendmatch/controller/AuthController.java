package com.friendmatch.controller;

import com.friendmatch.dto.*;
import com.friendmatch.model.User;
import com.friendmatch.security.JwtUtil;
import com.friendmatch.service.PasswordResetService;
import com.friendmatch.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final PasswordResetService passwordResetService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(request.getPassword());
        user.setName(request.getName());
        user.setAge(request.getAge());
        user.setBio(request.getBio());
        user.setGenero(request.getGenero());
        user.setLocalidad(request.getLocalidad());
        user.setDireccion(request.getDireccion());

        User savedUser = userService.registerUser(user, request.getInterestIds(), request.getMusicGenreIds());
        String token = jwtUtil.generateToken(savedUser.getEmail());
        return ResponseEntity.ok(new AuthResponse(token, savedUser.getId()));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        User user = userService.findByEmail(request.getEmail());
        if (user != null && passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            String token = jwtUtil.generateToken(user.getEmail());
            return ResponseEntity.ok(new AuthResponse(token, user.getId()));
        }
        return ResponseEntity.status(401).body("Credenciales incorrectas");
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        try {
            String resetToken = passwordResetService.generarToken(request.getEmail());
            return ResponseEntity.ok(Map.of(
                "mensaje", "Si el correo existe, recibirás un enlace de recuperación",
                "token", resetToken   // quitar en producción
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.ok(Map.of(
                "mensaje", "Si el correo existe, recibirás un enlace de recuperación"
            ));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        try {
            passwordResetService.restablecerContrasena(request.getToken(), request.getNewPassword());
            return ResponseEntity.ok(Map.of("mensaje", "Contraseña restablecida correctamente"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
