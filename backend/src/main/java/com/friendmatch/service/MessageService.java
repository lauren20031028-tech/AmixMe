package com.friendmatch.service;

import com.friendmatch.model.Message;
import com.friendmatch.model.Match;
import com.friendmatch.model.User;
import com.friendmatch.repository.MessageRepository;
import com.friendmatch.repository.MatchRepository;
import com.friendmatch.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {
    private final MessageRepository messageRepository;
    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    
    public Message sendMessage(@NonNull Long matchId, @NonNull Long senderId, @NonNull String text) {
        Match match = matchRepository.findById(matchId).orElseThrow();
        User sender = userRepository.findById(senderId).orElseThrow();
        
        Message message = new Message();
        message.setMatch(match);
        message.setSender(sender);
        message.setMessageText(text);
        return messageRepository.save(message);
    }
    
    public List<Message> getMatchMessages(@NonNull Long matchId) {
        return messageRepository.findByMatchIdOrderByCreatedAtAsc(matchId);
    }
}
