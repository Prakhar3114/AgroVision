// widgets/confidence_gauge.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ConfidenceGauge extends StatefulWidget {
  final double confidence; // 0 to 100
  const ConfidenceGauge({Key? key, required this.confidence}) : super(key: key);

  @override
  State<ConfidenceGauge> createState() => _ConfidenceGaugeState();
}

class _ConfidenceGaugeState extends State<ConfidenceGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.confidence).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns color based on confidence level
  Color _getColor(double value) {
    if (value >= 85) return const Color(0xFF00DC64); // Green — high confidence
    if (value >= 60) return const Color(0xFFFFB300); // Amber — medium
    return const Color(0xFFFF5252);                   // Red — low confidence
  }

  String _getLabel(double value) {
    if (value >= 85) return 'High';
    if (value >= 60) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final double val = _animation.value;
        final Color activeColor = _getColor(val);
        final double filled = val / 100;
        final double remaining = 1 - filled;

        return Column(
          children: [
            SizedBox(
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pie chart acting as radial gauge
                  PieChart(
                    PieChartData(
                      startDegreeOffset: 270,
                      sectionsSpace: 0,
                      centerSpaceRadius: 44,
                      sections: [
                        PieChartSectionData(
                          value: filled,
                          color: activeColor,
                          radius: 18,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: remaining,
                          color: const Color(0xFF1A3D28),
                          radius: 14,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),

                  // Center text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${val.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: activeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLabel(val),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4D7A5E),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Confidence label row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI Confidence Score',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF4D7A5E),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Segmented confidence bar
            _buildConfidenceBar(val, activeColor),
          ],
        );
      },
    );
  }

  Widget _buildConfidenceBar(double val, Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFF1A3D28),
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0%',
                style: TextStyle(fontSize: 9, color: Color(0xFF3D6B50))),
            Text('50%',
                style: TextStyle(fontSize: 9, color: Color(0xFF3D6B50))),
            Text('100%',
                style: TextStyle(fontSize: 9, color: Color(0xFF3D6B50))),
          ],
        ),
      ],
    );
  }
}