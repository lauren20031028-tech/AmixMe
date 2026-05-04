package com.friendmatch.repository;

import com.friendmatch.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByMatchIdOrderByCreatedAtAsc(Long matchId);
}
