// models/scan_result.dart
class ScanResult {
  final int? id;
  final String imagePath;
  final String plant;
  final String disease;
  final double confidence;
  final String treatment;
  final DateTime timestamp;

  ScanResult({
    this.id,
    required this.imagePath,
    required this.plant,
    required this.disease,
    required this.confidence,
    required this.treatment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'plant': plant,
      'disease': disease,
      'confidence': confidence,
      'treatment': treatment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String,
      plant: map['plant'] as String,
      disease: map['disease'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      treatment: map['treatment'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}