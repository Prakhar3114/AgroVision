// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://web-production-084da.up.railway.app/predict";

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    ).timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // treatment — safely handle List OR String
      String treatment = "";
      if (data["treatment"] is List) {
        treatment = (data["treatment"] as List).join("\n");
      } else {
        treatment = data["treatment"]?.toString() ?? "";
      }

      if (data["status"] == "invalid") {
        return {
          "status": "invalid",
          "plant": "",
          "disease": "",
          "confidence": data["confidence"]?.toString() ?? "",
          "treatment": data["message"] ?? "Invalid image. Please upload a plant leaf."
        };
      } else {
        return {
          "status": "success",
          "plant": data["plant"]?.toString() ?? "",
          "disease": data["disease"]?.toString() ?? "",
          "confidence": data["confidence"]?.toString() ?? "",
          "treatment": treatment,
        };
      }
    } else {
      throw Exception("Server error ${response.statusCode}: ${response.body}");
    }
  }
}