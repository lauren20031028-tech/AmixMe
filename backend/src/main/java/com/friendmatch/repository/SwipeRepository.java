package com.friendmatch.repository;

import com.friendmatch.model.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface SwipeRepository extends JpaRepository<Swipe, Long> {
    @Query("SELECT s FROM Swipe s WHERE s.swiper.id = :swiperId AND s.swiped.id = :swipedId")
    Optional<Swipe> findBySwipeIds(Long swiperId, Long swipedId);
    
    @Query("SELECT s FROM Swipe s WHERE s.swiper.id = :user2Id AND s.swiped.id = :user1Id AND s.isLike = true")
    Optional<Swipe> findMutualLike(Long user1Id, Long user2Id);
    
    // Likes enviados por el usuario (todos los que le dio like)
    @Query("SELECT s FROM Swipe s WHERE s.swiper.id = :userId AND s.isLike = true")
    List<Swipe> findLikesSentByUser(Long userId);
    
    // Likes recibidos por el usuario (personas que le dieron like)
    @Query("SELECT s FROM Swipe s WHERE s.swiped.id = :userId AND s.isLike = true")
    List<Swipe> findLikesReceivedByUser(Long userId);
}
