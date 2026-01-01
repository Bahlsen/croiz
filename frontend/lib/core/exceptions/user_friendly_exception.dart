/// Exception that provides both user-friendly and technical error messages.
///
/// Use this exception when you need to display a clean, user-friendly message
/// to the end user while still logging technical details for debugging.
///
/// Example:
/// ```dart
/// throw UserFriendlyException(
///   'Unable to generate puzzle. Please try again.',
///   technicalDetails: 'Firebase API returned 403: $errorMessage',
/// );
/// ```
class UserFriendlyException implements Exception {
  /// Creates a user-friendly exception.
  ///
  /// [userMessage] is the message shown to the end user.
  /// [technicalDetails] contains technical information for debugging (optional).
  UserFriendlyException(this.userMessage, {this.technicalDetails});

  /// The user-friendly message to display to the end user.
  final String userMessage;

  /// Technical details for logging and debugging (not shown to users).
  final String? technicalDetails;

  @override
  String toString() {
    if (technicalDetails != null) {
      return 'UserFriendlyException: $userMessage (Technical: $technicalDetails)';
    }
    return 'UserFriendlyException: $userMessage';
  }
}
