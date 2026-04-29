class DiseaseInfo {
  final String name;
  final String description;
  final String remedy;
  final String severity;
  final int color;

  const DiseaseInfo({
    required this.name,
    required this.description,
    required this.remedy,
    required this.severity,
    required this.color,
  });
}

const Map<String, DiseaseInfo> diseaseDatabase = {
  'Early Blight': DiseaseInfo(
    name: 'Early Blight',
    description:
        'Caused by Alternaria solani fungus. Appears as dark brown spots with '
        'concentric rings (target pattern) on older leaves first.',
    remedy:
        '• Apply copper-based fungicide (Copper Oxychloride)\n'
        '• Remove and destroy infected leaves immediately\n'
        '• Avoid overhead watering\n'
        '• Apply Mancozeb 75% WP @ 2g/L water every 7 days\n'
        '• Rotate crops the next season to break the cycle',
    severity: 'Moderate',
    color: 0xFFE65100,
  ),
  'Late Blight': DiseaseInfo(
    name: 'Late Blight',
    description:
        'Caused by Phytophthora infestans. Water-soaked lesions on leaves '
        'that turn brown/black rapidly. Highly destructive and spreads fast.',
    remedy:
        '• Spray Chlorothalonil or Cymoxanil immediately\n'
        '• Remove all infected plant parts and burn them\n'
        '• Apply Metalaxyl-M + Mancozeb fungicide\n'
        '• Improve field drainage to reduce moisture\n'
        '• Avoid planting in wet or humid conditions',
    severity: 'Severe',
    color: 0xFFB71C1C,
  ),
  'Leaf Mold': DiseaseInfo(
    name: 'Leaf Mold',
    description:
        'Caused by Passalora fulva fungus. Yellow patches appear on the upper '
        'leaf surface with olive-green mold growth on the underside.',
    remedy:
        '• Improve greenhouse or field ventilation\n'
        '• Reduce relative humidity below 85%\n'
        '• Apply Chlorothalonil or Copper fungicide weekly\n'
        '• Space plants adequately for better air circulation\n'
        '• Use resistant tomato varieties if available',
    severity: 'Moderate',
    color: 0xFF558B2F,
  ),
  'Septoria Spot': DiseaseInfo(
    name: 'Septoria Leaf Spot',
    description:
        'Caused by Septoria lycopersici. Small circular spots with dark '
        'borders and light gray centers. Starts on lower leaves and moves up.',
    remedy:
        '• Remove lower infected leaves immediately\n'
        '• Apply copper-based fungicide spray\n'
        '• Use Mancozeb or Chlorothalonil every 7–10 days\n'
        '• Mulch around plants to prevent soil splash\n'
        '• Avoid working with plants when they are wet',
    severity: 'Moderate',
    color: 0xFF6A1B9A,
  ),
  'Yellow Curl Leaf': DiseaseInfo(
    name: 'Yellow Leaf Curl',
    description:
        'Caused by Tomato Yellow Leaf Curl Virus (TYLCV), spread by '
        'whiteflies. Leaves curl upward and turn yellow with stunted growth.',
    remedy:
        '• No cure — remove and destroy all infected plants\n'
        '• Control whitefly population with Imidacloprid spray\n'
        '• Use yellow sticky traps to catch whiteflies early\n'
        '• Cover young plants with insect-proof nets\n'
        '• Plant virus-resistant tomato varieties next season',
    severity: 'Severe',
    color: 0xFFF9A825,
  ),
  'Healthy': DiseaseInfo(
    name: 'Healthy Leaf',
    description:
        'No disease detected. The tomato leaf appears healthy with normal '
        'coloration and structure. Keep up good farming practices.',
    remedy:
        '• Continue regular monitoring every 3–5 days\n'
        '• Maintain proper irrigation — avoid over-watering\n'
        '• Apply balanced fertilizer (NPK) as needed\n'
        '• Keep field free of weeds and debris\n'
        '• Ensure adequate sunlight and ventilation',
    severity: 'None',
    color: 0xFF2E7D32,
  ),
};
