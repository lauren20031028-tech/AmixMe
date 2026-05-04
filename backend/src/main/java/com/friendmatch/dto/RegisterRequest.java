package com.friendmatch.dto;

import lombok.Data;
import java.util.List;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private String name;
    private Integer age;
    private String bio;
    private String genero;
    private String localidad;
    private String direccion;
    /** IDs de intereses/pasatiempos seleccionados */
    private List<Long> interestIds;
    /** IDs de géneros musicales seleccionados */
    private List<Long> musicGenreIds;
}
