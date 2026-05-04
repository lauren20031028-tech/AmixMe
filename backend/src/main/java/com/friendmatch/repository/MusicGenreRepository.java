package com.friendmatch.repository;

import com.friendmatch.model.MusicGenre;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MusicGenreRepository extends JpaRepository<MusicGenre, Long> {
    List<MusicGenre> findAllByOrderByCategoriaAscNameAsc();
}
