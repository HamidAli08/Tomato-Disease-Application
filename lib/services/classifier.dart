import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  final String label;
  final double confidence;
  final int classIndex;
  final bool isNotLeaf;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.classIndex,
    this.isNotLeaf = false,
  });
}

class TomatoClassifier {
  // ─────────────────────────────────────────────────────────────────
  // ✅ CONFIGURATION
  // ─────────────────────────────────────────────────────────────────

  static const String modelPath = 'assets/models/best_float16.tflite';
  static const int inputSize = 224;

  // Inference thresholds (matched from web app)
  static const double confidenceThreshold = 0.65;
  static const double minMargin = 0.15;

  // Leaf pixel thresholds — relaxed to handle real phone photos
  // (hands holding leaf, outdoor backgrounds, shadows etc.)
  static const double minGreenPixelRatio = 0.12; // was 0.18 — relaxed
  static const double minLeafPixelRatio = 0.20; // was 0.42 — relaxed
  static const double maxSkinPixelRatio = 0.55; // was 0.12 — relaxed

  /// Class names — must match your data.yaml order exactly
  static const List<String> classNames = [
    'Early Blight',
    'Healthy',
    'Late Blight',
    'Yellow Curl Leaf',
    'Leaf Mold',
    'Septoria Spot',
  ];
  // ─────────────────────────────────────────────────────────────────

  Interpreter? _interpreter;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );
      _isLoaded = true;
      print('✅ Model loaded: $modelPath');
      print('   Input  shape: ${_interpreter!.getInputTensor(0).shape}');
      print('   Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      _isLoaded = false;
      print('❌ Failed to load model: $e');
    }
  }

  Future<ClassificationResult?> classify(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      print('⚠️  Classifier not loaded');
      return null;
    }

    try {
      // 1. Decode image
      final bytes = await imageFile.readAsBytes();
      img.Image? rawImage = img.decodeImage(bytes);
      if (rawImage == null) return null;

      // 2. Leaf pre-check
      if (!_hasEnoughGreenContent(rawImage)) {
        print('🚫 Rejected: not a leaf');
        return ClassificationResult(
          label: 'Not a Leaf',
          confidence: 0.0,
          classIndex: -1,
          isNotLeaf: true,
        );
      }

      // 3. Resize to 224×224
      img.Image resized = img.copyResize(
        rawImage,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      // 4. NHWC input tensor [1, 224, 224, 3]
      //    TFLite always uses NHWC regardless of ONNX format
      final inputTensor = _imageToFloat32NHWC(resized);

      // 5. Output tensor [1, 6]
      final outputTensor = [List<double>.filled(classNames.length, 0.0)];

      // 6. Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // 7. Parse result
      return _parseOutput(outputTensor[0]);
    } catch (e) {
      print('❌ Inference error: $e');
      return null;
    }
  }

  // ── NHWC: [1, H, W, 3] — correct format for TFLite ──────────────
  List<List<List<List<double>>>> _imageToFloat32NHWC(img.Image image) {
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

  // ── HSV leaf check ────────────────────────────────────────────────
  bool _hasEnoughGreenContent(img.Image image) {
    final step = (image.width / 20).round().clamp(1, 999);
    int green = 0, brown = 0, skin = 0, total = 0;

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final p = image.getPixel(x, y);
        final r = p.r / 255.0;
        final g = p.g / 255.0;
        final b = p.b / 255.0;

        final maxC = [r, g, b].reduce((a, b) => a > b ? a : b);
        final minC = [r, g, b].reduce((a, b) => a < b ? a : b);
        final delta = maxC - minC;
        final v = maxC;
        final s = maxC == 0 ? 0.0 : delta / maxC;

        double h = 0;
        if (delta != 0) {
          if (maxC == r) {
            h = ((g - b) / delta) % 6;
          } else if (maxC == g) {
            h = (b - r) / delta + 2;
          } else {
            h = (r - g) / delta + 4;
          }
          h *= 60;
          if (h < 0) h += 360;
        }

        final isGreen = h >= 70 &&
            h <= 165 &&
            s >= 0.22 &&
            v >= 0.18 &&
            v <= 0.95 &&
            g > r * 1.05 &&
            g > b * 1.1;

        final isBrown = h >= 18 &&
            h <= 48 &&
            s >= 0.32 &&
            v >= 0.16 &&
            v <= 0.7 &&
            r > g * 1.03 &&
            g > b * 1.05;

        final isSkin = h >= 0 &&
            h <= 55 &&
            s >= 0.18 &&
            s <= 0.7 &&
            v >= 0.3 &&
            r > g &&
            g > b;

        if (isGreen) green++;
        if (isBrown) brown++;
        if (isSkin) skin++;
        total++;
      }
    }

    if (total == 0) return false;

    final greenRatio = green / total;
    final leafRatio = (green + brown) / total;
    final skinRatio = skin / total;

    print('🌿 green=${(greenRatio * 100).toStringAsFixed(1)}%'
        ' leaf=${(leafRatio * 100).toStringAsFixed(1)}%'
        ' skin=${(skinRatio * 100).toStringAsFixed(1)}%');

    if (skinRatio > maxSkinPixelRatio) return false;
    if (leafRatio < minLeafPixelRatio || greenRatio < minGreenPixelRatio) {
      return false;
    }
    return true;
  }

  // ── Parse model output ────────────────────────────────────────────
  ClassificationResult? _parseOutput(List<double> rawScores) {
    // Apply softmax defensively (same as web app)
    final sum = rawScores.reduce((a, b) => a + b);
    final isAlreadySoftmax =
        sum > 0.95 && sum < 1.05 && rawScores.every((v) => v >= 0);

    List<double> probs;
    if (isAlreadySoftmax) {
      probs = List<double>.from(rawScores);
    } else {
      final maxScore = rawScores.reduce((a, b) => a > b ? a : b);
      final expVals = rawScores.map((v) => _safeExp(v - maxScore)).toList();
      final expSum = expVals.reduce((a, b) => a + b);
      probs = expVals.map((v) => v / expSum).toList();
    }

    // Best class
    int bestIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[bestIdx]) bestIdx = i;
    }
    final confidence = probs[bestIdx];

    // Margin between top and second
    final sorted = List<double>.from(probs)..sort((a, b) => b.compareTo(a));
    final margin = sorted[0] - sorted[1];

    print('🔍 Top: ${classNames[bestIdx]}'
        ' — ${(confidence * 100).toStringAsFixed(1)}%'
        ' margin=${(margin * 100).toStringAsFixed(1)}%');

    // Low confidence → not a leaf
    if (confidence < confidenceThreshold) {
      print('🚫 Low confidence — showing as Not a Leaf');
      return ClassificationResult(
        label: 'Not a Leaf',
        confidence: confidence,
        classIndex: -1,
        isNotLeaf: true,
      );
    }

    // Too close between classes → uncertain
    if (margin < minMargin) {
      print('🚫 Ambiguous result');
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
