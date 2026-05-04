package com.friendmatch.dto;

import lombok.Data;
import org.springframework.lang.NonNull;

@Data
public class MessageRequest {
    @NonNull
    private Long matchId;
    @NonNull
    private Long senderId;
    @NonNull
    private String text;
}
