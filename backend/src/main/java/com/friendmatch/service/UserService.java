package com.friendmatch.service;

import com.friendmatch.dto.UpdateProfileRequest;
import com.friendmatch.model.Interest;
import com.friendmatch.model.MusicGenre;
import com.friendmatch.model.User;
import com.friendmatch.repository.InterestRepository;
import com.friendmatch.repository.MusicGenreRepository;
import com.friendmatch.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final InterestRepository interestRepository;
    private final MusicGenreRepository musicGenreRepository;

    @Transactional
    public @NonNull User registerUser(@NonNull User user, List<Long> interestIds, List<Long> musicGenreIds) {
        user.setPasswordHash(passwordEncoder.encode(user.getPasswordHash()));
        asignarIntereses(user, interestIds);
        asignarGenerosMusicales(user, musicGenreIds);
        return userRepository.save(user);
    }

    @Transactional
    public @NonNull User updateProfile(@NonNull Long userId, @NonNull UpdateProfileRequest req) {
        User user = userRepository.findById(userId).orElseThrow();

        if (req.getName() != null)
            user.setName(req.getName());
        if (req.getAge() != null)
            user.setAge(req.getAge());
        if (req.getBio() != null)
            user.setBio(req.getBio());
        if (req.getGenero() != null)
            user.setGenero(req.getGenero());
        if (req.getLocalidad() != null)
            user.setLocalidad(req.getLocalidad());
        if (req.getDireccion() != null)
            user.setDireccion(req.getDireccion());

        if (req.getInterestIds() != null) {
            asignarIntereses(user, req.getInterestIds());
        }
        if (req.getMusicGenreIds() != null) {
            asignarGenerosMusicales(user, req.getMusicGenreIds());
        }

        return userRepository.save(user);
    }

    private void asignarIntereses(User user, List<Long> ids) {
        if (ids == null)
            return;
        Set<Interest> interests = new HashSet<>(interestRepository.findAllById(ids));
        user.setInterests(interests);
    }

    private void asignarGenerosMusicales(User user, List<Long> ids) {
        if (ids == null)
            return;
        Set<MusicGenre> genres = new HashSet<>(musicGenreRepository.findAllById(ids));
        user.setMusicGenres(genres);
    }

    @Nullable
    public User findByEmail(@NonNull String email) {
        return userRepository.findByEmail(email).orElse(null); // NOSONAR nullable by design
    }

    public Optional<User> findById(@NonNull Long userId) {
        return userRepository.findById(userId);
    }

    /**
     * Devuelve usuarias ordenadas por score de compatibilidad.
     * Score = intereses comunes * 2 + géneros musicales comunes * 1.5
     * Solo muestra usuarias con score >= 1 primero, luego el resto.
     */
    public List<User> findCompatibleUsers(@NonNull Long userId,
            @NonNull Double lat,
            @NonNull Double lon,
            @NonNull Integer maxDistance) {
        List<User> candidatas = userRepository.findNearbyUsers(userId, lat, lon, maxDistance);
        User yo = userRepository.findById(userId).orElse(null);
        if (yo == null)
            return candidatas;

        Set<Long> misIntereses = yo.getInterests() == null ? Set.of()
                : yo.getInterests().stream().map(Interest::getId).collect(Collectors.toSet());
        Set<Long> misGeneros = yo.getMusicGenres() == null ? Set.of()
                : yo.getMusicGenres().stream().map(MusicGenre::getId).collect(Collectors.toSet());

        return candidatas.stream()
                .sorted(Comparator.comparingDouble((User u) -> calcularScore(u, misIntereses, misGeneros)).reversed())
                .collect(Collectors.toList());
    }

    private double calcularScore(User u, Set<Long> misIntereses, Set<Long> misGeneros) {
        long interesesComunes = u.getInterests() == null ? 0
                : u.getInterests().stream().filter(i -> misIntereses.contains(i.getId())).count();
        long generosComunes = u.getMusicGenres() == null ? 0
                : u.getMusicGenres().stream().filter(g -> misGeneros.contains(g.getId())).count();
        return interesesComunes * 2.0 + generosComunes * 1.5;
    }

    public List<User> findNearbyUsers(@NonNull Long userId, @NonNull Double lat,
            @NonNull Double lon, @NonNull Integer maxDistance) {
        return userRepository.findNearbyUsers(userId, lat, lon, maxDistance);
    }

    public List<User> findByLocalidad(@NonNull Long userId, @NonNull String localidad) {
        return userRepository.findByLocalidad(userId, localidad);
    }

    /**
     * Busca por localidad y ordena por compatibilidad.
     */
    public List<User> findCompatibleByLocalidad(@NonNull Long userId, @NonNull String localidad) {
        List<User> candidatas = userRepository.findByLocalidad(userId, localidad);
        User yo = userRepository.findById(userId).orElse(null);
        if (yo == null)
            return candidatas;

        Set<Long> misIntereses = yo.getInterests() == null ? Set.of()
                : yo.getInterests().stream().map(Interest::getId).collect(Collectors.toSet());
        Set<Long> misGeneros = yo.getMusicGenres() == null ? Set.of()
                : yo.getMusicGenres().stream().map(MusicGenre::getId).collect(Collectors.toSet());

        return candidatas.stream()
                .sorted(Comparator.comparingDouble((User u) -> calcularScore(u, misIntereses, misGeneros)).reversed())
                .collect(Collectors.toList());
    }

    @Transactional
    public User updateLocation(@NonNull Long userId, @NonNull Double lat, @NonNull Double lon) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setLatitude(lat);
        user.setLongitude(lon);
        return userRepository.save(user);
    }

    public List<Interest> getAllInterests() {
        return interestRepository.findAllByOrderByCategoriaAscNameAsc();
    }

    public List<MusicGenre> getAllMusicGenres() {
        return musicGenreRepository.findAllByOrderByCategoriaAscNameAsc();
    }

    public List<User> findAllUsers() {
        return userRepository.findAll();
    }

    /**
     * Filtra usuarias por localidad y/o intereses/géneros musicales.
     * Si no se especifica localidad, usa la del usuario actual.
     * Ordena por compatibilidad basada en los filtros aplicados.
     */
    public List<User> filterUsers(@NonNull Long userId,
            @Nullable String localidad,
            @Nullable List<Long> interestIds,
            @Nullable List<Long> musicGenreIds) {
        User yo = userRepository.findById(userId).orElse(null);
        if (yo == null)
            return List.of();

        // Usar la localidad del usuario si no se especifica
        String loc = (localidad != null && !localidad.isBlank())
                ? localidad
                : yo.getLocalidad();

        // Obtener candidatos por localidad
        List<User> candidatas = (loc != null && !loc.isBlank())
                ? userRepository.findByLocalidad(userId, loc)
                : userRepository.findAll().stream()
                        .filter(u -> !u.getId().equals(userId))
                        .collect(Collectors.toList());

        // Filtrar por intereses si se especifican
        if (interestIds != null && !interestIds.isEmpty()) {
            Set<Long> filterInterests = new HashSet<>(interestIds);
            candidatas = candidatas.stream()
                    .filter(u -> u.getInterests() != null &&
                            u.getInterests().stream()
                                    .anyMatch(i -> filterInterests.contains(i.getId())))
                    .collect(Collectors.toList());
        }

        // Filtrar por géneros musicales si se especifican
        if (musicGenreIds != null && !musicGenreIds.isEmpty()) {
            Set<Long> filterGenres = new HashSet<>(musicGenreIds);
            candidatas = candidatas.stream()
                    .filter(u -> u.getMusicGenres() != null &&
                            u.getMusicGenres().stream()
                                    .anyMatch(g -> filterGenres.contains(g.getId())))
                    .collect(Collectors.toList());
        }

        // Calcular score basado en los filtros aplicados
        Set<Long> misIntereses = yo.getInterests() == null ? Set.of()
                : yo.getInterests().stream().map(Interest::getId).collect(Collectors.toSet());
        Set<Long> misGeneros = yo.getMusicGenres() == null ? Set.of()
                : yo.getMusicGenres().stream().map(MusicGenre::getId).collect(Collectors.toSet());

        return candidatas.stream()
                .sorted(Comparator.comparingDouble((User u) -> calcularScore(u, misIntereses, misGeneros)).reversed())
                .collect(Collectors.toList());
    }
}
