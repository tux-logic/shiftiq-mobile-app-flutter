class ApiEndpoints {
  ApiEndpoints._();

  // Environment Base URLs
  // Use 10.0.2.2 for Android emulator pointing to localhost, or production render URL
  static const String baseUrlProduction = 'https://shiftiq-platform.onrender.com';
  static const String baseUrlLocalAndroid = 'http://10.0.2.2:8080';
  static const String baseUrlLocal = 'http://localhost:8080';

  // Active base URL (default to production for immediate reliability)
  static String activeBaseUrl = baseUrlProduction;

  // IAM Authentication
  static const String login = '/api/v1/authentication/sessions';
  static const String googleLogin = '/api/v1/authentication/sessions/google';
  static const String refreshToken = '/api/v1/authentication/sessions/refresh';
  static const String logout = '/api/v1/authentication/sessions';
  static const String passwordRecoveries = '/api/v1/authentication/password-recoveries';
  static const String passwordResets = '/api/v1/authentication/password-resets';

  // Users & Profiles
  static const String userProfilesRoles = '/api/v1/profiles/roles';
  static const String userProfileByDocument = '/api/v1/profiles';
  static const String customers = '/api/v1/customers';
  static const String employees = '/api/v1/employees';
}
