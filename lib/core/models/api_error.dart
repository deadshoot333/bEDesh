class ApiError {
  final String message;
  final int? statusCode;

  ApiError({
    required this.message,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['error'] as String? ?? json['message'] as String? ?? 'Unknown error',
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  String toString() {
    return 'ApiError: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}
