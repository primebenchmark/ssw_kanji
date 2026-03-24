class AppConfig {
  final String key;
  final String value;

  const AppConfig({required this.key, required this.value});

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        key: json['key'] as String,
        value: json['value'] as String? ?? '',
      );
}
