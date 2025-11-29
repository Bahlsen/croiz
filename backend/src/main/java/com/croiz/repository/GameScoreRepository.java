package com.croiz.repository;

import com.croiz.entity.GameScore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GameScoreRepository extends JpaRepository<GameScore, String> {
	List<GameScore> findByUserId(String userId);

	List<GameScore> findByGameId(String gameId);

	List<GameScore> findByUserIdOrderByCompletedAtDesc(String userId);
}
