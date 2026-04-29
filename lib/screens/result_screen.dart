import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/classifier.dart';
import '../utils/disease_info.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final ClassificationResult result;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    // ── NEW: show dedicated screen when image is not a leaf ───────
    if (result.isNotLeaf) {
      return _NotLeafScreen(imageFile: imageFile);
    }
    // ─────────────────────────────────────────────────────────────

    // ── Everything below is YOUR original result_screen code ─────
    final info = diseaseDatabase[result.label];
    final color =
        info != null ? Color(info.color) : Colors.grey.shade600;
    final isHealthy = result.label == 'Healthy';
    final isUncertain = result.label == 'Uncertain';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          'Analysis Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Leaf image ────────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.file(
                    imageFile,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isUncertain
                            ? Colors.grey.shade700
                            : color,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHealthy
                                ? Icons.check_circle
                                : isUncertain
                                    ? Icons.help_outline
                                    : Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            result.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Confidence card ───────────────────────────────────
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isHealthy
                                ? Icons.eco_rounded
                                : isUncertain
                                    ? Icons.help_outline_rounded
                                    : Icons.bug_report_rounded,
                            color: color,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                info?.name ?? result.label,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              if (info != null) ...[
                                const SizedBox(height: 6),
                                _severityBadge(info.severity),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Confidence bar
                    Row(
                      children: [
                        const Text(
                          'Model confidence',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(result.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 12,
                      percent: result.confidence.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      progressColor: color,
                      barRadius: const Radius.circular(6),
                      padding: EdgeInsets.zero,
                    ),

                    if (isUncertain) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.amber.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Confidence is below threshold. '
                                'Try a clearer, well-lit photo.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF795548)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Description card ──────────────────────────────────
            if (info != null) ...[
              _infoCard(
                icon: Icons.info_outline_rounded,
                title: 'About this condition',
                content: info.description,
                accentColor: Colors.blue.shade700,
              ),
              const SizedBox(height: 12),

              // ── Remedy card ───────────────────────────────────
              _infoCard(
                icon: Icons.healing_rounded,
                title: isHealthy ? 'Care tips' : 'Treatment & remedy',
                content: info.remedy,
                accentColor: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 12),
            ],

            // ── All classes confidence (debug helper) ─────────────
            // Remove this card when not needed for FYP demo
            const SizedBox(height: 8),

            // ── Action buttons ────────────────────────────────────
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text(
                'Scan Another Leaf',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _severityBadge(String severity) {
    Color badgeColor;
    IconData icon;
    switch (severity) {
      case 'Severe':
        badgeColor = Colors.red.shade700;
        icon = Icons.priority_high_rounded;
        break;
      case 'Moderate':
        badgeColor = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        badgeColor = Colors.green.shade700;
        icon = Icons.check_rounded;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            'Severity: $severity',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color accentColor,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            Divider(
                height: 18,
                color: accentColor.withOpacity(0.15),
                thickness: 1),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.65,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── NEW: Separate widget shown when image is not a tomato leaf ────────
class _NotLeafScreen extends StatelessWidget {
  final File imageFile;
  const _NotLeafScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Analysis Result',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Image with red overlay + X icon
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.file(
                    imageFile,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.38),
                    colorBlendMode: BlendMode.darken,
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.88),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12)
                          ],
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main message card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.red.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.eco_outlined,
                      size: 54, color: Colors.red.shade400),
                  const SizedBox(height: 14),
                  const Text(
                    "This doesn't look like a tomato leaf",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please take a clear photo of a tomato leaf to '
                    'detect diseases accurately.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Color(0xFF2E7D32), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Tips for best results',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...[
                    '📷  Take a close-up photo of a single leaf',
                    '☀️  Ensure good lighting — avoid dark or blurry shots',
                    '🍃  The leaf should fill most of the frame',
                    '🚫  Avoid soil, stems, fruit, or other objects',
                  ].map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text(tip,
                            style: const TextStyle(
                                fontSize: 13, height: 1.5)),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Try again button
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
