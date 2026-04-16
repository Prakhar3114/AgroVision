// widgets/treatment_card.dart
import 'package:flutter/material.dart';

// ─── Data model for a single treatment step ──────────────────────────────────
class TreatmentStep {
  final String title;
  final String detail;
  final IconData icon;

  const TreatmentStep({
    required this.title,
    required this.detail,
    required this.icon,
  });
}

// ─── Severity levels ─────────────────────────────────────────────────────────
enum Severity { healthy, mild, moderate, severe }

// ─── Main widget ─────────────────────────────────────────────────────────────
class TreatmentCard extends StatefulWidget {
  final String disease;
  final String basicTreatment;

  const TreatmentCard({
    Key? key,
    required this.disease,
    required this.basicTreatment,
  }) : super(key: key);

  @override
  State<TreatmentCard> createState() => _TreatmentCardState();
}

class _TreatmentCardState extends State<TreatmentCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  int? _expandedStep;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
      _expandedStep = null;
    }
  }

  /// Generates context-aware treatment steps based on disease name
  List<TreatmentStep> _getSteps() {
    final String d = widget.disease.toLowerCase();

    if (d.contains('healthy')) {
      return [
        const TreatmentStep(
          title: 'No action needed',
          detail: 'Your plant is healthy. Continue regular watering and ensure adequate sunlight.',
          icon: Icons.check_circle_outline,
        ),
        const TreatmentStep(
          title: 'Preventive care',
          detail: 'Apply balanced NPK fertilizer every 2 weeks. Inspect leaves weekly for early signs.',
          icon: Icons.shield_outlined,
        ),
        const TreatmentStep(
          title: 'Monitor regularly',
          detail: 'Scan the plant every 7 days to catch any early disease onset.',
          icon: Icons.visibility_outlined,
        ),
      ];
    }

    if (d.contains('blight')) {
      return [
        const TreatmentStep(
          title: 'Immediate isolation',
          detail: 'Remove and bag all infected leaves and stems immediately. Do not compost them. Disinfect pruning tools with 70% alcohol.',
          icon: Icons.warning_amber_outlined,
        ),
        const TreatmentStep(
          title: 'Fungicide application',
          detail: 'Apply systemic fungicide (Mancozeb or Metalaxyl-M) every 7–10 days. Spray early morning or evening. Avoid spraying in direct sunlight.',
          icon: Icons.science_outlined,
        ),
        const TreatmentStep(
          title: 'Soil & drainage',
          detail: 'Ensure good soil drainage. Avoid overhead watering — use drip irrigation instead. Allow soil to dry between waterings.',
          icon: Icons.water_drop_outlined,
        ),
        const TreatmentStep(
          title: 'Prevention for next crop',
          detail: 'Use certified disease-free seed. Practice 3-year crop rotation. Plant resistant varieties.',
          icon: Icons.autorenew,
        ),
      ];
    }

    if (d.contains('rust') || d.contains('scab')) {
      return [
        const TreatmentStep(
          title: 'Remove infected parts',
          detail: 'Prune all infected leaves showing rust pustules or scab lesions. Burn or dispose in sealed bags.',
          icon: Icons.content_cut,
        ),
        const TreatmentStep(
          title: 'Copper-based fungicide',
          detail: 'Apply copper sulfate or copper hydroxide spray. Repeat every 10 days. Ensure full leaf coverage including underside.',
          icon: Icons.science_outlined,
        ),
        const TreatmentStep(
          title: 'Improve air circulation',
          detail: 'Space plants adequately. Prune dense canopy to allow airflow. Avoid high humidity conditions.',
          icon: Icons.air,
        ),
      ];
    }

    if (d.contains('spot') || d.contains('mold') || d.contains('mildew')) {
      return [
        const TreatmentStep(
          title: 'Remove affected leaves',
          detail: 'Identify and remove all spotted or moldy leaves at first sign. Dispose safely away from garden.',
          icon: Icons.delete_outline,
        ),
        const TreatmentStep(
          title: 'Sulfur or neem spray',
          detail: 'Apply sulfur-based fungicide or neem oil solution (2ml per litre water) weekly. Good for organic farming.',
          icon: Icons.eco_outlined,
        ),
        const TreatmentStep(
          title: 'Reduce moisture',
          detail: 'Water at base level only. Increase plant spacing. Ensure morning watering so leaves dry before night.',
          icon: Icons.water_drop_outlined,
        ),
        const TreatmentStep(
          title: 'Follow-up monitoring',
          detail: 'Re-scan in 5 days. If spreading, switch to systemic fungicide. Consult agronomist if uncontrolled.',
          icon: Icons.monitor_heart_outlined,
        ),
      ];
    }

    if (d.contains('bacterial')) {
      return [
        const TreatmentStep(
          title: 'Isolate immediately',
          detail: 'Bacterial infections spread fast. Remove and destroy infected plant parts. Sterilize all tools.',
          icon: Icons.block,
        ),
        const TreatmentStep(
          title: 'Copper bactericide',
          detail: 'Apply copper-based bactericide spray every 5–7 days. Avoid overhead irrigation to prevent splash spread.',
          icon: Icons.science_outlined,
        ),
        const TreatmentStep(
          title: 'Adjust soil pH',
          detail: 'Maintain soil pH between 6.0–7.0. Test soil and amend with lime if too acidic.',
          icon: Icons.science_outlined,
        ),
      ];
    }

    if (d.contains('virus') || d.contains('mosaic') || d.contains('curl')) {
      return [
        const TreatmentStep(
          title: 'No chemical cure',
          detail: 'Viral diseases have no direct treatment. Focus on removing infected plants to stop spread to healthy ones.',
          icon: Icons.warning_outlined,
        ),
        const TreatmentStep(
          title: 'Control insect vectors',
          detail: 'Viruses spread via whiteflies and aphids. Apply insecticide (Imidacloprid) to control vector population.',
          icon: Icons.bug_report_outlined,
        ),
        const TreatmentStep(
          title: 'Destroy infected plants',
          detail: 'Uproot and burn severely infected plants. Do not replant susceptible varieties in same plot for 1 season.',
          icon: Icons.local_fire_department_outlined,
        ),
        const TreatmentStep(
          title: 'Use resistant varieties',
          detail: 'For next crop, choose certified virus-resistant seed varieties from an accredited supplier.',
          icon: Icons.shield_outlined,
        ),
      ];
    }

    // Default steps for any other disease
    return [
      TreatmentStep(
        title: 'Immediate action',
        detail: widget.basicTreatment,
        icon: Icons.priority_high,
      ),
      const TreatmentStep(
        title: 'Apply fungicide',
        detail: 'Use a broad-spectrum fungicide appropriate for the plant type. Follow label instructions carefully.',
        icon: Icons.science_outlined,
      ),
      const TreatmentStep(
        title: 'Preventive measures',
        detail: 'Improve drainage, reduce leaf wetness, and maintain proper plant spacing to prevent recurrence.',
        icon: Icons.shield_outlined,
      ),
      const TreatmentStep(
        title: 'Expert consultation',
        detail: 'If disease persists after 2 weeks, consult a local agricultural extension officer or agronomist.',
        icon: Icons.support_agent_outlined,
      ),
    ];
  }

  Severity _getSeverity() {
    final String d = widget.disease.toLowerCase();
    if (d.contains('healthy')) return Severity.healthy;
    if (d.contains('virus') || d.contains('curl') || d.contains('blight'))
      return Severity.severe;
    if (d.contains('bacterial') || d.contains('mosaic'))
      return Severity.moderate;
    return Severity.mild;
  }

  Color _severityColor(Severity s) {
    switch (s) {
      case Severity.healthy:
        return const Color(0xFF00DC64);
      case Severity.mild:
        return const Color(0xFF00DC64).withOpacity(0.7);
      case Severity.moderate:
        return const Color(0xFFFFB300);
      case Severity.severe:
        return const Color(0xFFFF5252);
    }
  }

  String _severityLabel(Severity s) {
    switch (s) {
      case Severity.healthy:
        return 'Healthy';
      case Severity.mild:
        return 'Mild';
      case Severity.moderate:
        return 'Moderate';
      case Severity.severe:
        return 'Severe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    final severity = _getSeverity();
    final severityColor = _severityColor(severity);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A3D28)),
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: _toggleExpand,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Protocol icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00DC64).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF00DC64).withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF00DC64),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + severity badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Treatment Protocol',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8FFF2),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: severityColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: severityColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _severityLabel(severity),
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: severityColor,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${steps.length} steps',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF3D6B50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF4D7A5E),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsed summary (always visible) ──────────────────────────────
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF060D09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1A2E22)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF3D6B50), size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.basicTreatment,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8AB89A),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Expanded steps ───────────────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Divider
                  const Divider(color: Color(0xFF1A3D28), height: 1),
                  const SizedBox(height: 12),

                  ...List.generate(steps.length, (i) {
                    final step = steps[i];
                    final bool isOpen = _expandedStep == i;
                    return _buildStepTile(
                      step: step,
                      index: i,
                      isOpen: isOpen,
                      isLast: i == steps.length - 1,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile({
    required TreatmentStep step,
    required int index,
    required bool isOpen,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: () => setState(
          () => _expandedStep = isOpen ? null : index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Step row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step number + connector line
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isOpen
                          ? const Color(0xFF00DC64)
                          : const Color(0xFF00DC64).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00DC64).withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isOpen
                              ? const Color(0xFF060D09)
                              : const Color(0xFF00DC64),
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 1,
                      height: isOpen ? 0 : 20,
                      color: const Color(0xFF1A3D28),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Step title + icon
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(step.icon,
                            size: 14, color: const Color(0xFF4D7A5E)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE8FFF2),
                            ),
                          ),
                        ),
                        Icon(
                          isOpen
                              ? Icons.remove
                              : Icons.add,
                          size: 14,
                          color: const Color(0xFF3D6B50),
                        ),
                      ],
                    ),

                    // Expanded detail
                    if (isOpen) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060D09),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF1A2E22)),
                        ),
                        child: Text(
                          step.detail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8AB89A),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    if (!isLast) const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}