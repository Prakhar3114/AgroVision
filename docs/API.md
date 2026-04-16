# 📡 API Documentation

## Base URL

```
Production: https://agrovision-api.railway.app
Development: http://localhost:5000
```

---

## Authentication

All endpoints support optional authentication via Firebase token in header:

```http
Authorization: Bearer <firebase_id_token>
```

---

## Endpoints

### 1. Health Check

Check if API is running and model is loaded.

```http
GET /health
```

**Request Example:**
```bash
curl -X GET https://agrovision-api.railway.app/health
```

**Response (200 OK):**
```json
{
  "status": "ok",
  "model_loaded": true,
  "api_version": "1.0",
  "uptime": 3600,
  "timestamp": "2024-04-15T10:30:00Z"
}
```

**Response (500 Error):**
```json
{
  "status": "error",
  "message": "Model not loaded",
  "error": "TensorFlow Lite initialization failed"
}
```

---

### 2. Predict Plant Disease

Main endpoint for disease prediction. Accepts base64 encoded image.

```http
POST /predict
Content-Type: application/json
```

**Request Body:**
```json
{
  "image": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  "user_id": "firebase_user_id_optional"
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| image | string | Yes | Base64 encoded image (JPG/PNG) |
| user_id | string | No | Firebase user ID for analytics |

**Image Requirements:**
- **Format**: JPG or PNG
- **Size**: Max 5MB
- **Dimensions**: Any size (will be resized to 224×224)
- **Encoding**: Must be valid base64

**Response (200 OK):**
```json
{
  "status": "success",
  "disease": "Early Blight",
  "class_id": 5,
  "confidence": 0.9234,
  "accuracy": "92.34%",
  "severity": "High",
  "recommendations": [
    "Apply fungicide spray (e.g., mancozeb, chlorothalonil)",
    "Remove infected leaves immediately",
    "Ensure good air circulation",
    "Water at base of plant, avoid wetting leaves",
    "Remove fallen leaves from ground"
  ],
  "info": {
    "disease_name": "Early Blight (Alternaria solani)",
    "common_names": ["Early leaf spot", "Target spot", "Early blight"],
    "affected_plants": ["Tomato", "Potato", "Pepper"],
    "conditions": "Warm (68-80°F), humid, wet leaves",
    "prevention": [
      "Space plants for air circulation",
      "Mulch to prevent soil splashing",
      "Stake/cage plants off ground",
      "Remove lower leaves on tomatoes"
    ]
  },
  "treatment": {
    "immediate": [
      "Remove infected leaves",
      "Apply fungicide"
    ],
    "ongoing": [
      "Monitor daily",
      "Reapply fungicide every 7-10 days"
    ],
    "cost": "Low to Medium"
  },
  "processing_time_ms": 1234,
  "timestamp": "2024-04-15T10:30:00Z"
}
```

**Response (400 Bad Request):**
```json
{
  "status": "error",
  "error": "Invalid image format",
  "message": "Image must be valid JPG or PNG",
  "code": 400
}
```

**Response (413 Payload Too Large):**
```json
{
  "status": "error",
  "error": "Image too large",
  "message": "Maximum image size is 5MB",
  "code": 413
}
```

**Response (500 Server Error):**
```json
{
  "status": "error",
  "error": "Inference failed",
  "message": "TensorFlow Lite model execution failed",
  "code": 500
}
```

**Python Request Example:**
```python
import requests
import base64
import json

# Read and encode image
with open('plant_image.jpg', 'rb') as f:
    image_base64 = base64.b64encode(f.read()).decode('utf-8')

# Prepare request
url = "https://agrovision-api.railway.app/predict"
payload = {
    "image": image_base64,
    "user_id": "user123"
}

# Send request
response = requests.post(url, json=payload)
result = response.json()

# Handle response
if result['status'] == 'success':
    print(f"Disease: {result['disease']}")
    print(f"Confidence: {result['confidence']}")
    print(f"Recommendations: {result['recommendations']}")
else:
    print(f"Error: {result['error']}")
```

**JavaScript Request Example:**
```javascript
async function predictDisease(imageFile) {
  // Read and encode image
  const reader = new FileReader();
  
  reader.onload = async (e) => {
    const imageData = e.target.result;
    const base64Image = imageData.split(',')[1];
    
    // Send to API
    const response = await fetch('https://agrovision-api.railway.app/predict', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        image: base64Image,
        user_id: 'user123'
      })
    });
    
    const result = await response.json();
    
    if (result.status === 'success') {
      console.log(`Disease: ${result.disease}`);
      console.log(`Confidence: ${result.confidence}`);
    } else {
      console.error(`Error: ${result.error}`);
    }
  };
  
  reader.readAsDataURL(imageFile);
}
```

**cURL Request Example:**
```bash
# First, encode image to base64
base64 -i plant_image.jpg > image.b64

# Read base64 and send request
curl -X POST https://agrovision-api.railway.app/predict \
  -H "Content-Type: application/json" \
  -d '{
    "image": "'$(cat image.b64)'",
    "user_id": "user123"
  }'
```

**Dart/Flutter Request Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map> predictDisease(List<int> imageBytes) async {
  final String base64Image = base64Encode(imageBytes);
  
  final response = await http.post(
    Uri.parse('https://agrovision-api.railway.app/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'image': base64Image,
      'user_id': 'user123'
    }),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('API Error: ${response.statusCode}');
  }
}
```

---

### 3. Model Information

Get metadata about the ML model.

```http
GET /model/info
```

**Request Example:**
```bash
curl -X GET https://agrovision-api.railway.app/model/info
```

**Response (200 OK):**
```json
{
  "model_name": "Plant Disease Classifier CNN",
  "version": "1.0",
  "framework": "TensorFlow Lite",
  "total_classes": 39,
  "healthy_class": 0,
  "input_shape": {
    "batch": 1,
    "height": 224,
    "width": 224,
    "channels": 3
  },
  "output_shape": {
    "batch": 1,
    "classes": 39
  },
  "accuracy": 0.94,
  "validation_accuracy": 0.93,
  "model_size_mb": 15.2,
  "inference_time_ms": 1200,
  "training_dataset": {
    "name": "PlantVillage Dataset",
    "size": 54000,
    "classes": 38,
    "augmentation": true
  },
  "diseases": [
    {
      "class_id": 0,
      "name": "Apple Healthy",
      "category": "Healthy"
    },
    {
      "class_id": 1,
      "name": "Apple Scab",
      "category": "Fungal"
    },
    {
      "class_id": 2,
      "name": "Apple Black rot",
      "category": "Fungal"
    },
    // ... 36 more diseases
  ],
  "preprocessing": {
    "resize": "224x224",
    "normalization": "0-1 scale",
    "color_space": "RGB"
  },
  "performance": {
    "precision": 0.92,
    "recall": 0.91,
    "f1_score": 0.915
  },
  "last_updated": "2024-04-01T00:00:00Z"
}
```

---

## Error Handling

### Standard Error Response Format

```json
{
  "status": "error",
  "error": "error_type",
  "message": "human_readable_message",
  "code": 400,
  "timestamp": "2024-04-15T10:30:00Z"
}
```

### HTTP Status Codes

| Code | Meaning | When It Occurs |
|------|---------|---|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid image format, missing parameters |
| 413 | Payload Too Large | Image size exceeds limit |
| 500 | Internal Server Error | Model inference failed |
| 503 | Service Unavailable | API temporarily down |

### Common Errors

**Invalid Image Format:**
```json
{
  "status": "error",
  "error": "invalid_format",
  "message": "Image must be valid JPG or PNG",
  "code": 400
}
```

**Image Too Large:**
```json
{
  "status": "error",
  "error": "image_too_large",
  "message": "Maximum image size is 5MB (received 6.2MB)",
  "code": 413
}
```

**Model Not Loaded:**
```json
{
  "status": "error",
  "error": "model_not_ready",
  "message": "Model is still initializing, please try again",
  "code": 503
}
```

---

## Rate Limiting

Current rate limits:
- **Free tier**: 100 requests/hour
- **Production**: No limit (monitored)

Rate limit headers in response:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1234567890
```

---

## CORS Policy

The API allows requests from:
- `localhost:*`
- `*.railway.app`
- Registered app domains

Add headers:
```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

---

## Performance Metrics

### Expected Response Times

| Scenario | Time |
|----------|------|
| Health check | ~50ms |
| Model info | ~100ms |
| Image prediction (1MB) | ~1000-1500ms |
| Large image (5MB) | ~2000-3000ms |

### Optimization Tips

1. **Compress images**: Use JPEG 85% quality
2. **Right size**: 224×224 preferred (no resize needed)
3. **Batch requests**: Send multiple at once
4. **Cache responses**: Reuse predictions for same image
5. **Monitor latency**: Log request times

---

## Webhook Events (Future)

```
POST /webhooks/register
{
  "event_type": "prediction_complete",
  "url": "https://yourapp.com/webhook",
  "secret": "webhook_secret"
}
```

---

## API Versioning

Current API version: **1.0**

Future versions will use:
```
https://agrovision-api.railway.app/v2/predict
```

---

## Support

For issues:
1. Check [SETUP.md](./SETUP.md) for configuration
2. Review error message and logs
3. Open issue on [GitHub](https://github.com/Prakhar3114/AgroVision)

---

**API v1.0** | Last updated: April 2024
