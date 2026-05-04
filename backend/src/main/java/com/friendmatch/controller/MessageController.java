package com.friendmatch.controller;

import com.friendmatch.dto.MessageRequest;
import com.friendmatch.model.Message;
import com.friendmatch.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {
    private final MessageService messageService;
    
    @PostMapping
    public ResponseEntity<Message> sendMessage(@RequestBody @NonNull MessageRequest request) {
        return ResponseEntity.ok(messageService.sendMessage(
            request.getMatchId(),
            request.getSenderId(),
            request.getText()
        ));
    }
    
    @GetMapping("/match/{matchId}")
    public ResponseEntity<List<Message>> getMessages(@PathVariable @NonNull Long matchId) {
        return ResponseEntity.ok(messageService.getMatchMessages(matchId));
    }
}
