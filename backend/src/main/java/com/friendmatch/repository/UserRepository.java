package com.friendmatch.repository;

import com.friendmatch.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    @Query(value = "SELECT u.* FROM users u " +
           "WHERE u.id != :userId " +
           "AND u.is_active = true " +
           "AND u.id NOT IN (SELECT swiped_id FROM swipes WHERE swiper_id = :userId) " +
           "AND (6371 * acos(cos(radians(:lat)) * cos(radians(u.latitude)) * " +
           "cos(radians(u.longitude) - radians(:lon)) + sin(radians(:lat)) * " +
           "sin(radians(u.latitude)))) <= :maxDistance " +
           "ORDER BY RAND() LIMIT 20", nativeQuery = true)
    List<User> findNearbyUsers(@Param("userId") Long userId,
                               @Param("lat") Double latitude,
                               @Param("lon") Double longitude,
                               @Param("maxDistance") Integer maxDistance);

    @Query(value = "SELECT u.* FROM users u " +
           "WHERE u.id != :userId " +
           "AND u.is_active = true " +
           "AND u.localidad = :localidad " +
           "AND u.id NOT IN (SELECT swiped_id FROM swipes WHERE swiper_id = :userId) " +
           "ORDER BY RAND() LIMIT 20", nativeQuery = true)
    List<User> findByLocalidad(@Param("userId") Long userId,
                               @Param("localidad") String localidad);
}
