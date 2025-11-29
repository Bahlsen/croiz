package com.croiz.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

	@ExceptionHandler(ResourceNotFoundException.class)
	public ResponseEntity<Map<String, Object>> handleResourceNotFound(
			ResourceNotFoundException ex) {
		log.warn("Resource not found: {}", ex.getMessage());
		Map<String, Object> response = new HashMap<>();
		response.put("error", "NOT_FOUND");
		response.put("message", ex.getMessage());
		response.put("status", HttpStatus.NOT_FOUND.value());
		return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
	}

	@ExceptionHandler(IllegalArgumentException.class)
	public ResponseEntity<Map<String, Object>> handleIllegalArgument(
			IllegalArgumentException ex) {
		log.warn("Invalid argument: {}", ex.getMessage());
		Map<String, Object> response = new HashMap<>();
		response.put("error", "BAD_REQUEST");
		response.put("message", ex.getMessage());
		response.put("status", HttpStatus.BAD_REQUEST.value());
		return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<Map<String, Object>> handleGenericException(Exception ex) {
		log.error("Unexpected error", ex);
		Map<String, Object> response = new HashMap<>();
		response.put("error", "INTERNAL_SERVER_ERROR");
		response.put("message", "An unexpected error occurred");
		response.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
				.body(response);
	}
}
