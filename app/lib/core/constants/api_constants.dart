class ApiConstants {
  // Backend URL - Deployed on Google Cloud Run
  static const String baseUrl =
      'https://quotebot-backend-421764703984.us-central1.run.app';

  // Endpoints
  static String get uploadUrl => '$baseUrl/upload-url';
  static String get analyze => '$baseUrl/analyze';
  static String jobs(String jobId) => '$baseUrl/jobs/$jobId';
  static String get projects => '$baseUrl/projects';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout =
      Duration(minutes: 5); // For large video uploads

  // Polling Configuration
  static const Duration pollingInterval = Duration(seconds: 3);
  static const int maxPollingAttempts = 100; // Max 5 minutes of polling

  // Upload Configuration
  static const int maxVideoSizeMB = 100;
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];
}
