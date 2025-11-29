package com.croiz.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "games")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Game {

	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private String id;

	@Column(nullable = false)
	private String title;

	@Column(nullable = false)
	private Integer gridSize = 15;

	@Column(nullable = false)
	private Integer difficulty = 1; // 1=easy, 2=medium, 3=hard

	@Column(columnDefinition = "TEXT")
	private String gridData;

	@Column(columnDefinition = "TEXT")
	private String cluesData;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private LocalDateTime createdAt;

	@Column(nullable = false)
	private Boolean active = true;
}
