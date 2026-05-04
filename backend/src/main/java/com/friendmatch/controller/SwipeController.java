package com.friendmatch.controller;

import com.friendmatch.dto.SwipeRequest;
import com.friendmatch.model.Match;
import com.friendmatch.model.User;
import com.friendmatch.service.SwipeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/swipes")
@RequiredArgsConstructor
public class SwipeController {
    private final SwipeService swipeService;
    
    @PostMapping
    public ResponseEntity<?> swipe(@RequestBody @NonNull SwipeRequest request) {
        Match match = swipeService.processSwipe(
            request.getSwiperId(), 
            request.getSwipedId(), 
            request.getIsLike()
        );
        
        if (match != null) {
            return ResponseEntity.ok(match);
        }
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/sent/{userId}")
    public ResponseEntity<List<User>> getLikesSent(@PathVariable @NonNull Long userId) {
        List<User> likesSent = swipeService.getLikesSentByUser(userId);
        return ResponseEntity.ok(likesSent);
    }
    
    @GetMapping("/received/{userId}")
    public ResponseEntity<List<User>> getLikesReceived(@PathVariable @NonNull Long userId) {
        List<User> likesReceived = swipeService.getLikesReceivedByUser(userId);
        return ResponseEntity.ok(likesReceived);
    }
}
