// screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_app/services/api_service.dart';
import 'package:plant_disease_app/widgets/confidence_gauge.dart';
import 'package:plant_disease_app/widgets/treatment_card.dart';
import 'package:plant_disease_app/services/db_service.dart';
import 'package:plant_disease_app/models/scan_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardFade = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  // ─── Image picking ──────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) return;

    setState(() {
      _selectedImage = File(file.path);
      _result = null;
    });
    _cardController.reset();
    await _analyzeImage();
  }

  // ─── API call ───────────────────────────────────────────────────────────────
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() => _isLoading = true);

    try {
      final data = await _apiService.uploadImage(_selectedImage!);
      setState(() {
        _result = data;
        _isLoading = false;
      });

      if (data['status'] == 'invalid') {
        // Show invalid image bottom sheet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showInvalidSheet(data['confidence']?.toString() ?? '');
        });
      } else {
        // Animate result card in
        _cardController.forward();

        // Save to history
        await DbService.instance.insertScan(ScanResult(
          imagePath: _selectedImage!.path,
          plant: data['plant'] ?? '',
          disease: data['disease'] ?? '',
          confidence: double.tryParse(data['confidence'].toString()) ?? 0,
          treatment: data['treatment'] ?? '',
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnack(e.toString());
    }
  }

  // ─── Invalid image bottom sheet ─────────────────────────────────────────────
  void _showInvalidSheet(String confidence) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1A12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3D28),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFFF5252).withOpacity(0.3)),
              ),
              child: const Icon(Icons.image_not_supported_outlined,
                  color: Color(0xFFFF5252), size: 30),
            ),

            const SizedBox(height: 16),

            const Text(
              'Invalid Image Detected',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8FFF2),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              confidence.isNotEmpty
                  ? 'Model confidence was too low ($confidence%). Please upload a clear, close-up photo of a plant leaf.'
                  : 'Please upload a clear, close-up photo of a plant leaf with good lighting.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8AB89A),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 8),

            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF060D09),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1A2E22)),
              ),
              child: Column(
                children: const [
                  _TipRow(icon: Icons.center_focus_strong_outlined,
                      text: 'Fill the frame with the leaf'),
                  SizedBox(height: 6),
                  _TipRow(icon: Icons.wb_sunny_outlined,
                      text: 'Use natural or bright lighting'),
                  SizedBox(height: 6),
                  _TipRow(icon: Icons.blur_off,
                      text: 'Ensure image is sharp and in focus'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGrid(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildScanZone(),
                      const SizedBox(height: 16),
                      _buildButtonRow(),
                      const SizedBox(height: 20),
                      if (_selectedImage != null) _buildImagePreview(),
                      if (_result != null && _result!['status'] == 'success')
                        _buildResultCard(),
                      const SizedBox(height: 40),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // ─── Grid background ────────────────────────────────────────────────────────
  Widget _buildGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Online badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00DC64).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFF00DC64).withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00DC64),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'ONLINE',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF00DC64),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Logo
              Image.asset('assets/app_logo.png', height: 32),
            ],
          ),

          const SizedBox(height: 14),

          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'AGRO',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8FFF2),
                    letterSpacing: 2,
                  ),
                ),
                TextSpan(
                  text: 'VISION',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00DC64),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'SMART PLANT DISEASE DETECTION',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF3D6B50),
              letterSpacing: 2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scan zone ──────────────────────────────────────────────────────────────
  Widget _buildScanZone() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF00DC64).withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00DC64).withOpacity(0.2),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Corner brackets
          ..._buildCorners(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.document_scanner_outlined,
                    color: Color(0xFF3D6B50), size: 28),
                SizedBox(height: 8),
                Text(
                  'Scan or upload a leaf image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3D6B50),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const color = Color(0xFF00DC64);
    const size = 14.0;
    const thick = 2.0;
    const offset = 8.0;

    return [
      // Top-left
      Positioned(
        top: offset, left: offset,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thick),
              left: BorderSide(color: color, width: thick),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: offset, right: offset,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thick),
              right: BorderSide(color: color, width: thick),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: offset, left: offset,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thick),
              left: BorderSide(color: color, width: thick),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: offset, right: offset,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thick),
              right: BorderSide(color: color, width: thick),
            ),
          ),
        ),
      ),
    ];
  }

  // ─── Button row ─────────────────────────────────────────────────────────────
  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined, size: 16),
            label: const Text('Gallery'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text('Scan Now'),
          ),
        ),
      ],
    );
  }

  // ─── Image preview ──────────────────────────────────────────────────────────
  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.file(
              _selectedImage!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Analyzed badge
            if (_result != null && _result!['status'] == 'success')
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00DC64).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF00DC64).withOpacity(0.4)),
                  ),
                  child: const Text(
                    'ANALYZED',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF00DC64),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Result card ─────────────────────────────────────────────────────────────
  Widget _buildResultCard() {
    final r = _result!;
    final double confidence =
        double.tryParse(r['confidence'].toString()) ?? 0;

    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info rows ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1A12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1A3D28)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.local_florist_outlined, 'PLANT',
                      r['plant'] ?? ''),
                  const Divider(color: Color(0xFF1A2E22), height: 20),
                  _infoRow(Icons.bug_report_outlined, 'DISEASE',
                      r['disease'] ?? ''),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Confidence gauge ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1A12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1A3D28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined,
                          color: Color(0xFF4D7A5E), size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'CONFIDENCE ANALYSIS',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF3D6B50),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConfidenceGauge(confidence: confidence),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Treatment protocol ─────────────────────────────────────────
            TreatmentCard(
              disease: r['disease'] ?? '',
              basicTreatment: r['treatment'] ?? '',
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF00DC64).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4D7A5E), size: 15),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF3D6B50),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE8FFF2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Powered by CNN  •  AgroVision v1.0.0',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xFF2A4D38),
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ─── Loading overlay ─────────────────────────────────────────────────────────
  Widget _buildLoadingOverlay() {
    return Container(
      color: const Color(0xFF060D09).withOpacity(0.85),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1A12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF00DC64).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: const Color(0xFF00DC64),
                  backgroundColor:
                      const Color(0xFF00DC64).withOpacity(0.15),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ANALYZING CROP',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00DC64),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Running CNN inference...',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF3D6B50),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grid background painter ─────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00DC64).withOpacity(0.03)
      ..strokeWidth = 0.5;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ─── Tip row helper ──────────────────────────────────────────────────────────
class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF4D7A5E)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8AB89A),
          ),
        ),
      ],
    );
  }
}