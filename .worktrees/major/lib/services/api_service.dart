// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your backend URL later when deployed on Render
  final String baseUrl = "http://192.168.29.154:5000/predict";

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      // ✅ Safe handling of nulls and invalid images
      if (data["status"] == "invalid") {
        return {
          "status": "invalid",
          "plant": "",
          "disease": "",
          "confidence": data["confidence"]?.toString() ?? "",
          "treatment": data["message"] ?? "Invalid image. Please upload a plant leaf."
        };
      } else if (data["status"] == "success") {
        return {
          "status": "success",
          "plant": data["plant"]?.toString() ?? "",
          "disease": data["disease"]?.toString() ?? "",
          "confidence": data["confidence"]?.toString() ?? "",
          "treatment": data["treatment"]?.toString() ?? ""
        };
      } else {
        // Unknown response structure
        return {
          "status": "invalid",
          "plant": "",
          "disease": "",
          "confidence": "",
          "treatment": "Unexpected response from server."
        };
      }
    } else {
      throw Exception("Failed to get prediction");
    }
  }
}