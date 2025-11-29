package com.croiz.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {

	@JsonProperty("id")
	private String id;

	@JsonProperty("username")
	private String username;

	@JsonProperty("email")
	private String email;

	@JsonProperty("total_games_played")
	private Integer totalGamesPlayed;

	@JsonProperty("games_won")
	private Integer gamesWon;

	@JsonProperty("total_score")
	private Long totalScore;
}
