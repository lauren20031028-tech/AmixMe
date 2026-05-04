package com.friendmatch.repository;

import com.friendmatch.model.UserPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface UserPhotoRepository extends JpaRepository<UserPhoto, Long> {
    
    @Query("SELECT up FROM UserPhoto up WHERE up.user.id = :userId ORDER BY up.photoOrder ASC")
    List<UserPhoto> findByUserIdOrderByPhotoOrder(Long userId);
    
    @Query("SELECT up FROM UserPhoto up WHERE up.user.id = :userId AND up.isPrimary = true")
    Optional<UserPhoto> findPrimaryPhotoByUserId(Long userId);
    
    @Query("SELECT COUNT(up) FROM UserPhoto up WHERE up.user.id = :userId")
    Long countByUserId(Long userId);
    
    void deleteByUserIdAndPhotoOrder(Long userId, Integer photoOrder);
}