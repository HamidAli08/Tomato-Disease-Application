import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  final String label;
  final double confidence;
  final int classIndex;
  final bool isNotLeaf; // ← NEW: true when image is not a tomato leaf

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.classIndex,
    this.isNotLeaf = false, // ← defaults to false so existing code unaffected
  });
}

class TomatoClassifier {
  // ─────────────────────────────────────────────────────────────────
  // ✅ CONFIGURATION — adjust these to match your exported model
  // ─────────────────────────────────────────────────────────────────

  /// Path to your TFLite model inside the assets/models/ folder.
  /// Make sure the filename matches exactly (case-sensitive).
  static const String modelPath = 'assets/models/best_float32.tflite';

  /// Input image size your model was trained with (YOLOv8 default = 640).
  static const int inputSize = 224;

  /// Minimum confidence to accept a prediction (0.0 – 1.0).
  static const double confidenceThreshold = 0.20;

  /// If the top class score after softmax is still below this value,
  /// the scores are near-uniform (model is confused) → treat as non-leaf.
  static const double notLeafThreshold = 0.30;

  /// Class names in the EXACT order your model was trained.
  /// YOLOv8 sorts classes alphabetically by default — verify with your
  /// data.yaml file and reorder here if needed.
  static const List<String> classNames = [
    'Early Blight',
    'Healthy',
    'Late Blight',
    'Leaf Mold',
    'Septoria Spot',
    'Yellow Curl Leaf',
  ];

  // ─────────────────────────────────────────────────────────────────

  Interpreter? _interpreter;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Call once at app startup to load the model into memory.
  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );
      _isLoaded = true;

      // Print shapes to console for debugging
      print('✅ Model loaded: $modelPath');
      print('   Input  shape: ${_interpreter!.getInputTensor(0).shape}');
      print('   Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      _isLoaded = false;
      print('❌ Failed to load model: $e');
      print('   → Check that $modelPath exists in your assets folder');
      print('   → Check pubspec.yaml includes assets/models/');
    }
  }

  /// Run inference on an image file. Returns null on error.
  Future<ClassificationResult?> classify(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      print('⚠️  Classifier not loaded — call loadModel() first');
      return null;
    }

    try {
      // 1. Decode image
      final bytes = await imageFile.readAsBytes();
      img.Image? rawImage = img.decodeImage(bytes);
      if (rawImage == null) {
        print('⚠️  Could not decode image');
        return null;
      }

      // ── NEW: green-pixel pre-check ─────────────────────────────
      // Tomato leaves are green. If the image has very little green
      // content, reject it before running the model.
      if (!_hasEnoughGreenContent(rawImage)) {
        print('🚫 Rejected: not enough green pixels');
        return ClassificationResult(
          label: 'Not a Leaf',
          confidence: 0.0,
          classIndex: -1,
          isNotLeaf: true,
        );
      }
      // ──────────────────────────────────────────────────────────

      // 2. Resize to model input size
      img.Image resized = img.copyResize(
        rawImage,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      // 3. Build Float32 input tensor [1, 224, 224, 3]
      final inputTensor = _imageToFloat32(resized);

      // 4. Build output tensor matching the model's output shape
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputSize = outputShape.reduce((a, b) => a * b);
      final outputFlat = List.filled(outputSize, 0.0);
      final outputTensor = outputFlat.reshape(outputShape);

      // 5. Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // 6. Parse predictions
      return _parseOutput(outputTensor, outputShape);
    } catch (e) {
      print('❌ Inference error: $e');
      return null;
    }
  }

  // ── NEW: green content check ─────────────────────────────────────
  // Samples a grid of pixels. Returns false if fewer than 8% are "leaf green".
  bool _hasEnoughGreenContent(img.Image image) {
    final step = (image.width / 20).round().clamp(1, 999);
    int green = 0, total = 0;

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final lum = r + g + b;
        // Pixel is "leaf green" if green dominates and image isn't
        // too dark (shadow) or too bright (blown out)
        if (lum > 60 && lum < 700) {
          if (g > r && g > b && (g - r) > 10 && (g - b) > 5) {
            green++;
          }
        }
        total++;
      }
    }

    if (total == 0) return false;
    final ratio = green / total;
    print('🌿 Green pixel ratio: ${(ratio * 100).toStringAsFixed(1)}%');
    return ratio >= 0.08; // at least 8% green pixels required
  }
  // ─────────────────────────────────────────────────────────────────

  /// Convert an [img.Image] to a nested Float32 list of shape [1,H,W,3].
  List<List<List<List<double>>>> _imageToFloat32(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
  }

  /// Handle both classification outputs [1, N] and detection outputs [1, N, M].
  ClassificationResult? _parseOutput(dynamic output, List<int> shape) {
    List<double> scores = [];

    if (shape.length == 2 && shape[1] == classNames.length) {
      // ── Classification export: [1, num_classes] ──────────────────
      scores = List<double>.from(output[0].map((v) => v.toDouble()));
    } else if (shape.length == 3) {
      // ── Detection export: aggregate class scores across anchors ──
      scores = List.filled(classNames.length, 0.0);
      final anchors = output[0]; // shape [num_anchors, num_cols]
      for (var anchor in anchors) {
        // YOLOv8 detect: first 4 values are box coords, then class scores
        for (int c = 0; c < classNames.length; c++) {
          final idx = 4 + c;
          if (anchor is List && idx < anchor.length) {
            double score = anchor[idx].toDouble();
            if (score > scores[c]) scores[c] = score;
          }
        }
      }
    } else {
      print('⚠️  Unexpected output shape: $shape');
      print('   → Update _parseOutput() in classifier.dart to match');
      return null;
    }

    // Softmax normalisation (handles raw logits)
    double maxScore = scores.reduce((a, b) => a > b ? a : b);
    double expSum = scores.fold(0.0, (s, v) => s + _safeExp(v - maxScore));
    List<double> probs =
        scores.map((v) => _safeExp(v - maxScore) / expSum).toList();

    int bestIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[bestIdx]) bestIdx = i;
    }
    double confidence = probs[bestIdx];

    print('🔍 Top: ${classNames[bestIdx]} — ${(confidence * 100).toStringAsFixed(1)}%');

    // ── NEW: second layer — if model is still confused, reject ────
    if (confidence < notLeafThreshold) {
      print('🚫 Rejected: model confidence too low (not a leaf)');
      return ClassificationResult(
        label: 'Not a Leaf',
        confidence: confidence,
        classIndex: -1,
        isNotLeaf: true,
      );
    }
    // ─────────────────────────────────────────────────────────────

    if (confidence < confidenceThreshold) {
      return ClassificationResult(
        label: 'Uncertain',
        confidence: confidence,
        classIndex: -1,
      );
    }

    return ClassificationResult(
      label: classNames[bestIdx],
      confidence: confidence,
      classIndex: bestIdx,
    );
  }

  double _safeExp(double x) {
    if (x > 20) return 485165195.4;
    if (x < -20) return 0.0;
    double r = 1.0, t = 1.0;
    for (int i = 1; i <= 15; i++) {
      t *= x / i;
      r += t;
    }
    return r < 0 ? 0.0 : r;
  }

  void dispose() {
    _interpreter?.close();
    _isLoaded = false;
  }
}
