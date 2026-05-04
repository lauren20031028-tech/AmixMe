package com.friendmatch.dto;

import lombok.Data;
import java.util.List;

@Data
public class UpdateProfileRequest {
    private String name;
    private Integer age;
    private String bio;
    private String genero;
    private String localidad;
    private String direccion;
    private List<Long> interestIds;
    private List<Long> musicGenreIds;
}
