package com.croiz.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

	@JsonProperty("token")
	private String token;

	@JsonProperty("user")
	private UserDto user;

	@JsonProperty("expires_in")
	private Long expiresIn;
}
