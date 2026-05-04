package com.friendmatch.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "swipes")
@Data
public class Swipe {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "swiper_id", nullable = false)
    private User swiper;
    
    @ManyToOne
    @JoinColumn(name = "swiped_id", nullable = false)
    private User swiped;
    
    @Column(name = "is_like", nullable = false)
    private Boolean isLike;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
