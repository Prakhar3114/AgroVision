// screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  Map<String, dynamic>? predictionResult;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        predictionResult = null;
      });

      await _sendImageToApi();
    }
  }

  Future<void> _sendImageToApi() async {
    if (_selectedImage == null) return;

    setState(() => isLoading = true);

    try {
      var result = await _apiService.uploadImage(_selectedImage!);

      setState(() {
        predictionResult = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🌿 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1FAF5A), Color(0xFF0C5F33)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 20),

                    // 🟢 Logo
                    Image.asset(
                      'assets/app_logo.png',
                      height: 90,
                    ),

                    const SizedBox(height: 15),

                    // 🟢 App Name
                    const Text(
                      "AgroVision",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // 📷 Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo),
                            label: const Text("Gallery"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                              elevation: 6,
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                              elevation: 6,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // 🖼 Image Preview
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _selectedImage != null
                          ? _glassCard(
                              key: ValueKey(_selectedImage),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),

                    const SizedBox(height: 20),

                    // 📊 Result Card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: predictionResult != null
                          ? _glassCard(
                              key: ValueKey(predictionResult),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  _infoRow(
                                      Icons.local_florist,
                                      "Plant",
                                      predictionResult!['plant']),

                                  _infoRow(
                                      Icons.warning,
                                      "Disease",
                                      predictionResult!['disease']),

                                  _infoRow(
                                      Icons.analytics,
                                      "Confidence",
                                      "${predictionResult!['confidence']}%"),

                                  const Divider(
                                      color: Colors.white70),

                                  const Text(
                                    "Treatment",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.white),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    predictionResult!['treatment'],
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Powered by AI • v1.0.0",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // 🔄 Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Analyzing Crop...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child, Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _infoRow(
      IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "$title: ",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}