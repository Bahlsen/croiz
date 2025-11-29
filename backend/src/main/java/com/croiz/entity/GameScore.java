package com.croiz.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "game_scores")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GameScore {

	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private String id;

	@ManyToOne
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@ManyToOne
	@JoinColumn(name = "game_id", nullable = false)
	private Game game;

	@Column(nullable = false)
	private Integer score = 0;

	@Column(name = "time_taken_seconds", nullable = false)
	private Integer timeTakenSeconds;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private LocalDateTime completedAt;
}
