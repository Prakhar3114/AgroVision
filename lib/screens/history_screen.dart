// screens/history_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_disease_app/models/scan_result.dart';
import 'package:plant_disease_app/services/db_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanResult> _scans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final scans = await DbService.instance.getAllScans();
    setState(() {
      _scans = scans;
      _loading = false;
    });
  }

  Future<void> _deleteScan(int id) async {
    await DbService.instance.deleteScan(id);
    await _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan deleted')),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1A12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear history',
            style: TextStyle(color: Color(0xFFE8FFF2))),
        content: const Text('Delete all scan records? This cannot be undone.',
            style: TextStyle(color: Color(0xFF8AB89A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF4D7A5E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete all',
                style: TextStyle(color: Color(0xFFFF5252))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DbService.instance.clearAll();
      await _loadHistory();
    }
  }

  Color _confidenceColor(double c) {
    if (c >= 85) return const Color(0xFF00DC64);
    if (c >= 60) return const Color(0xFFFFB300);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00DC64)))
                  : _scans.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SCAN HISTORY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8FFF2),
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Past detection results',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF3D6B50),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (_scans.isNotEmpty)
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFFF5252).withOpacity(0.2)),
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFF5252),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1A12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1A3D28)),
            ),
            child: const Icon(Icons.history,
                color: Color(0xFF1A3D28), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF4D7A5E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your scan history will appear here',
            style: TextStyle(fontSize: 12, color: Color(0xFF2A4D38)),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: const Color(0xFF00DC64),
      backgroundColor: const Color(0xFF0D1A12),
      onRefresh: _loadHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _scans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildScanTile(_scans[i]),
      ),
    );
  }

  Widget _buildScanTile(ScanResult scan) {
    final color = _confidenceColor(scan.confidence);
    final bool imageExists =
        scan.imagePath.isNotEmpty && File(scan.imagePath).existsSync();
    final String dateStr = _formatDate(scan.timestamp);

    return Dismissible(
      key: Key(scan.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline,
            color: Color(0xFFFF5252), size: 22),
      ),
      onDismissed: (_) => _deleteScan(scan.id!),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1A12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1A3D28)),
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: const Color(0xFF4D7A5E),
          collapsedIconColor: const Color(0xFF3D6B50),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageExists
                ? Image.file(
                    File(scan.imagePath),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFF1A3D28),
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFF3D6B50), size: 20),
                  ),
          ),
          title: Text(
            scan.disease,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE8FFF2),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  scan.plant,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF4D7A5E)),
                ),
                const Text(' • ',
                    style:
                        TextStyle(fontSize: 11, color: Color(0xFF2A4D38))),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF2A4D38))),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${scan.confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Icon(Icons.keyboard_arrow_down,
                  color: const Color(0xFF3D6B50), size: 16),
            ],
          ),
          children: [
            const Divider(color: Color(0xFF1A2E22), height: 1),
            const SizedBox(height: 12),
            // Full image
            if (imageExists)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(scan.imagePath),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            // Confidence bar
            Row(
              children: [
                const Icon(Icons.analytics_outlined,
                    color: Color(0xFF4D7A5E), size: 13),
                const SizedBox(width: 6),
                const Text('Confidence',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF4D7A5E))),
                const Spacer(),
                Text(
                  '${scan.confidence.toStringAsFixed(2)}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: scan.confidence / 100,
                minHeight: 5,
                backgroundColor: const Color(0xFF1A3D28),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 12),
            // Treatment
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF060D09),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1A2E22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medical_services_outlined,
                      color: Color(0xFF3D6B50), size: 13),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scan.treatment,
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}