package com.croiz.repository;

import com.croiz.entity.Game;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GameRepository extends JpaRepository<Game, String> {
	List<Game> findAllByActiveTrue();

	List<Game> findByDifficulty(Integer difficulty);
}
