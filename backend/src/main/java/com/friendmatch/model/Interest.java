package com.friendmatch.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "interests")
@Data
public class Interest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String name;

    @Column(nullable = false)
    private String categoria;
}
