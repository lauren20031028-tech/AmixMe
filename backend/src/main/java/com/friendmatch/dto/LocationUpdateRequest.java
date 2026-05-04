package com.friendmatch.dto;

import lombok.Data;
import org.springframework.lang.NonNull;

@Data
public class LocationUpdateRequest {
    @NonNull
    private Double latitude;
    @NonNull
    private Double longitude;
}
