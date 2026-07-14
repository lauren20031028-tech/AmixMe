package com.friendmatch.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.List;

@Entity
@Table(name = "users")
@Data
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Integer age;

    @Column(columnDefinition = "TEXT")
    private String bio;

    /** Género de la persona: Mujer, Hombre, No binario, Prefiero no decir */
    private String genero;

    /** Localidad de Bogotá */
    private String localidad;

    /** Dirección o barrio (opcional) */
    private String direccion;

    @Column(name = "profile_photo_url")
    private String profilePhotoUrl;

    private Double latitude;
    private Double longitude;

    @Column(name = "max_distance")
    private Integer maxDistance = 10;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_interests",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "interest_id")
    )
    private Set<Interest> interests;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_music_genres",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "genre_id")
    )
    private Set<MusicGenre> musicGenres;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @OrderBy("photoOrder ASC")
    private List<UserPhoto> photos;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
