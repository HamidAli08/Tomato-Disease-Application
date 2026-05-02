# 🍅 Tomato Leaf Disease Detector — FYP Project

Offline Android app built with Flutter + YOLOv8n TFLite.
Detects 6 conditions: Early Blight, Late Blight, Leaf Mold,
Septoria Spot, Yellow Curl Leaf, and Healthy.

---

## ✅ Quick Start (3 steps)

### Step 1 — Add your model file
Copy your `best_float32.tflite` into:
```
assets/models/best_float32.tflite
```
> If your filename is different, update `modelPath` in `lib/services/classifier.dart` line ~20.

---

### Step 2 — Install Flutter packages
```bash
flutter pub get
```

---

### Step 3 — Run on Android device
```bash
flutter run
```

Or build a release APK:
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
lib/
├── main.dart                  ← App entry point
├── screens/
│   ├── home_screen.dart       ← Camera + gallery UI
│   └── result_screen.dart     ← Disease result display
├── services/
│   └── classifier.dart        ← TFLite inference engine  ← EDIT HERE
└── utils/
    └── disease_info.dart      ← Disease descriptions & remedies

assets/
└── models/
    └── best_float16.tflite    ← YOUR MODEL FILE GOES HERE

android/
└── app/
    ├── build.gradle           ← noCompress tflite (already set)
    └── src/main/
        ├── AndroidManifest.xml
        └── res/xml/file_paths.xml
```

---

## ⚙️ Configuration (classifier.dart)

Open `lib/services/classifier.dart` and check these settings:

```dart
// Line ~20 — model filename
static const String modelPath = 'assets/models/best_float32.tflite';

// Line ~25 — input image size (YOLOv8 default = 640)
static const int inputSize = 640;

// Line ~28 — minimum confidence to show result
static const double confidenceThreshold = 0.40;

// Lines ~31-38 — class names in the ORDER your model was trained
// Check your data.yaml file for the correct order!
static const List<String> classNames = [
  'Early Blight',
  'Healthy',
  'Late Blight',
  'Leaf Mold',
  'Septoria Spot',
  'Yellow Curl Leaf',
];
```

> **Important:** The class names must match your `data.yaml` order exactly.
> YOLOv8 sorts classes alphabetically by default.

---

## 🔍 Verify Output Shape

When you run the app, check the debug console for:
```
✅ Model loaded: assets/models/best_float32.tflite
   Input  shape: [1, 640, 640, 3]
   Output shape: [1, 6]          ← classification
          OR
   Output shape: [1, 84, 8400]   ← detection (also handled)
```

Both shapes are handled automatically.

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| tflite_flutter | Run TFLite model on-device |
| image_picker | Camera & gallery access |
| image | Image resizing & preprocessing |
| permission_handler | Camera/storage permissions |
| percent_indicator | Confidence progress bar |

---

## 🛠️ Requirements

- Flutter SDK 3.0+
- Android minSdkVersion 24 (Android 7.0+)
- Physical Android device recommended for camera
