import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Calls the native Vision framework via a method channel to OCR receipt images.
/// iOS side (Swift) uses VNRecognizeTextRequest.
class OcrService {
  static const _channel = MethodChannel('com.splitfair/vision');

  OcrService._();

  static final instance = OcrService._();

  /// Scans an image and returns parsed receipt lines.
  ///
  /// [imageBytes] — raw PNG/JPEG bytes of the receipt image.
  /// Returns a list of [ReceiptLine] objects with confidence >= 0.7.
  Future<List<ReceiptLine>> scanImage(Uint8List imageBytes) async {
    final result = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'recognizeText',
      {'imageBytes': imageBytes},
    );
    if (result == null) return [];
    return result
        .map((e) => ReceiptLine.fromMap(Map<String, dynamic>.from(e)))
        .where((line) => line.confidence >= 0.7)
        .toList();
  }
}

/// A single parsed line from a receipt, with a description and price.
class ReceiptLine {
  /// Item description (e.g. 'Pad Thai').
  final String description;

  /// Parsed price from the receipt.
  final String priceRaw;

  /// OCR confidence score (0.0–1.0).
  final double confidence;

  const ReceiptLine({
    required this.description,
    required this.priceRaw,
    required this.confidence,
  });

  /// Deserialize from the platform channel result map.
  factory ReceiptLine.fromMap(Map<String, dynamic> map) => ReceiptLine(
    description: map['description'] as String? ?? '',
    priceRaw: map['price'] as String? ?? '0',
    confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
  );
}
