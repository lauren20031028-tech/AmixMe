package com.friendmatch.controller;

import com.friendmatch.dto.LocationUpdateRequest;
import com.friendmatch.dto.UpdateProfileRequest;
import com.friendmatch.model.Interest;
import com.friendmatch.model.MusicGenre;
import com.friendmatch.model.User;
import com.friendmatch.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping("/interests")
    public ResponseEntity<List<Interest>> getAllInterests() {
        return ResponseEntity.ok(userService.getAllInterests());
    }

    @GetMapping("/music-genres")
    public ResponseEntity<List<MusicGenre>> getAllMusicGenres() {
        return ResponseEntity.ok(userService.getAllMusicGenres());
    }

    /** Perfil de una usuaria por ID */
    @GetMapping("/{userId}")
    public ResponseEntity<User> getUserById(@PathVariable @NonNull Long userId) {
        return userService.findById(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /** TEMPORAL: Listar todos los usuarios para debug */
    @GetMapping("/debug/all")
    public ResponseEntity<List<User>> getAllUsersDebug() {
        return ResponseEntity.ok(userService.findAllUsers());
    }

    /** Actualizar perfil (nombre, bio, intereses, música, etc.) */
    @PutMapping("/{userId}/profile")
    public ResponseEntity<User> updateProfile(
            @PathVariable @NonNull Long userId,
            @RequestBody @NonNull UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(userId, request));
    }

    /**
     * Usuarias compatibles ordenadas por score de intereses + música.
     * Usa GPS si se proveen lat/lon, si no usa localidad.
     */
    @GetMapping("/compatible/{userId}")
    public ResponseEntity<List<User>> getCompatibleUsers(
            @PathVariable @NonNull Long userId,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lon,
            @RequestParam(defaultValue = "15") int maxDistance,
            @RequestParam(required = false) String localidad) {

        if (lat != null && lon != null) {
            return ResponseEntity.ok(
                    userService.findCompatibleUsers(userId, lat, lon, maxDistance));
        } else if (localidad != null && !localidad.isBlank()) {
            return ResponseEntity.ok(
                    userService.findCompatibleByLocalidad(userId, localidad));
        } else {
            return ResponseEntity.ok(List.of());
        }
    }

    /** Usuarias cercanas por distancia (sin ordenar por compatibilidad) */
    @GetMapping("/nearby/{userId}")
    public ResponseEntity<List<User>> getNearbyUsers(
            @PathVariable @NonNull Long userId,
            @RequestParam @NonNull Double lat,
            @RequestParam @NonNull Double lon,
            @RequestParam(defaultValue = "15") @NonNull Integer maxDistance) {
        return ResponseEntity.ok(userService.findNearbyUsers(userId, lat, lon, maxDistance));
    }

    /** Usuarias en la misma localidad */
    @GetMapping("/localidad/{userId}")
    public ResponseEntity<List<User>> getUsersByLocalidad(
            @PathVariable @NonNull Long userId,
            @RequestParam @NonNull String localidad) {
        return ResponseEntity.ok(userService.findByLocalidad(userId, localidad));
    }

    @PutMapping("/{userId}/location")
    public ResponseEntity<User> updateLocation(
            @PathVariable @NonNull Long userId,
            @RequestBody @NonNull LocationUpdateRequest request) {
        return ResponseEntity.ok(
                userService.updateLocation(userId, request.getLatitude(), request.getLongitude()));
    }

    /**
     * Busca usuarias filtrando por localidad y/o intereses.
     * Ordena por compatibilidad basada en los filtros aplicados.
     */
    @GetMapping("/filter/{userId}")
    public ResponseEntity<List<User>> filterUsers(
            @PathVariable @NonNull Long userId,
            @RequestParam(required = false) String localidad,
            @RequestParam(required = false) List<Long> interestIds,
            @RequestParam(required = false) List<Long> musicGenreIds) {
        return ResponseEntity.ok(
                userService.filterUsers(userId, localidad, interestIds, musicGenreIds));
    }
}
