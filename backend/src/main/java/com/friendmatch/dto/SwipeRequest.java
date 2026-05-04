package com.friendmatch.dto;

import lombok.Data;
import org.springframework.lang.NonNull;

@Data
public class SwipeRequest {
    @NonNull
    private Long swiperId;
    @NonNull
    private Long swipedId;
    @NonNull
    private Boolean isLike;
}
