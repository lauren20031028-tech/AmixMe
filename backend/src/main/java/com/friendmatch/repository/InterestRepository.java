package com.friendmatch.repository;

import com.friendmatch.model.Interest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface InterestRepository extends JpaRepository<Interest, Long> {
    List<Interest> findAllByOrderByCategoriaAscNameAsc();
}
