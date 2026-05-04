package com.friendmatch.controller;

import com.friendmatch.model.Match;
import com.friendmatch.repository.MatchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/matches")
@RequiredArgsConstructor
public class MatchController {
    private final MatchRepository matchRepository;
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Match>> getUserMatches(@PathVariable @NonNull Long userId) {
        return ResponseEntity.ok(matchRepository.findUserMatches(userId));
    }
}
