package com.friendmatch.dto;

import lombok.Data;
import org.springframework.lang.NonNull;

@Data
public class LoginRequest {
    @NonNull
    private String email;
    @NonNull
    private String password;
}
