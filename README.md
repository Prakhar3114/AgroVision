# 🌱 AgroVision: Plant Disease Detection System

![Python](https://img.shields.io/badge/Python-3.9+-blue?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square)
![TensorFlow](https://img.shields.io/badge/TensorFlow-Lite-orange?style=flat-square)
![Firebase](https://img.shields.io/badge/Firebase-Auth-yellow?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

A real-time plant disease detection system combining deep learning (CNN), Flask backend, Flutter mobile app, and Firebase authentication. Designed for farmers and agricultural professionals to quickly identify plant diseases from photos.

## ✨ Features

- 🎥 **Real-time Detection**: Capture plant photos and get instant disease predictions
- 🔐 **Secure Authentication**: Email/password and Google Sign-In via Firebase
- 📱 **Dark-Themed UI**: Modern, user-friendly interface optimized for outdoor use
- 💾 **Scan History**: Persistent storage of detection history with image records
- ⚡ **Lightweight Model**: Optimized TensorFlow Lite model (~15MB) for mobile deployment
- 🌐 **REST API**: Backend API for predictions and data management
- 📊 **High Accuracy**: CNN-based classifier with ~94% accuracy on validation set

## 🛠️ Tech Stack

### Backend
- **Framework**: Flask (Python 3.9+)
- **ML/DL**: TensorFlow, Keras
- **Model Format**: TensorFlow Lite (.tflite)
- **Deployment**: Railway.app
- **Database**: SQLite (for scan history)

### Frontend (Mobile)
- **Framework**: Flutter (Dart 3.0+)
- **Authentication**: Firebase Auth (Email + Google OAuth)
- **Local Storage**: SQLite, shared_preferences
- **UI Design**: Material Design 3 with dark theme
- **Fonts**: Space Mono, Sora

### Infrastructure
- **Backend URL**: https://agrovision-api.railway.app
- **Authentication**: Firebase (Firestore, Auth)
- **Image Storage**: Device local storage (path_provider)

## 📂 Project Structure

```
agrovision/
├── backend/
│   ├── app.py                          # Flask main application
│   ├── convert_model.py                # Model conversion script (TF to TFLite)
│   ├── plant_disease_model.tflite      # Pre-trained TFLite model (Git LFS)
│   ├── requirements.txt                # Python dependencies
│   ├── Procfile                        # Railway deployment config
│   ├── .python-version                 # Python version specification
│   └── utils/
│       └── prediction.py               # Prediction helper functions
│
├── lib/                                # Flutter main code
│   ├── main.dart                       # App entry point
│   ├── screens/
│   │   ├── splash_screen.dart          # App splash/loading
│   │   ├── login_screen.dart           # Authentication UI
│   │   ├── home_screen.dart            # Main camera interface
│   │   └── history_screen.dart         # Scan history display
│   ├── services/
│   │   ├── api_service.dart            # Backend API communication
│   │   ├── auth_service.dart           # Firebase authentication
│   │   └── db_service.dart             # Local SQLite management
│   ├── models/                         # Data models/classes
│   └── widgets/                        # Reusable UI components
│
├── pubspec.yaml                        # Flutter dependencies & config
├── assets/                             # Images, fonts, icons
├── android/                            # Android native code (Kotlin DSL)
├── ios/                                # iOS native code
├── README.md                           # This file
├── .gitignore                          # Git ignore rules
├── .gitattributes                      # Git LFS configuration
└── docs/                               # Additional documentation
    ├── SETUP.md                        # Detailed setup guide
    ├── ARCHITECTURE.md                 # System design & architecture
    ├── API.md                          # API endpoints documentation
    └── MODELS.md                       # Model info & retraining guide
```

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Flutter 3.0+
- Git LFS (for model files)
- Firebase account
- Android SDK / Xcode (for mobile)

### Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run Flask server
python app.py

# Server runs at http://localhost:5000
```

### Frontend Setup

```bash
# Navigate to frontend
cd ..

# Get Flutter dependencies
flutter pub get

# Run on Android device/emulator
flutter run

# Or build APK
flutter build apk --release

# APK location: build/app/outputs/apk/release/app-release.apk
```

## 📡 API Documentation

### Base URL
```
https://agrovision-api.railway.app
```

### Endpoints

#### 1. Predict Plant Disease
- **Method**: `POST`
- **Route**: `/predict`
- **Request Body**:
  ```json
  {
    "image": "base64_encoded_image_string"
  }
  ```
- **Response** (Success - 200):
  ```json
  {
    "disease": "Early Blight",
    "confidence": 0.92,
    "class_id": 5,
    "recommendations": [
      "Apply fungicide",
      "Remove affected leaves",
      "Improve air circulation"
    ],
    "timestamp": "2024-04-15T10:30:00Z"
  }
  ```
- **Response** (Error - 400):
  ```json
  {
    "error": "Invalid image format",
    "status": "error"
  }
  ```

#### 2. Health Check
- **Method**: `GET`
- **Route**: `/health`
- **Response**:
  ```json
  {
    "status": "ok",
    "model_loaded": true,
    "api_version": "1.0"
  }
  ```

#### 3. Model Information
- **Method**: `GET`
- **Route**: `/model/info`
- **Response**:
  ```json
  {
    "model_name": "Plant Disease Classifier CNN",
    "version": "1.0",
    "total_classes": 39,
    "input_shape": [1, 224, 224, 3],
    "accuracy": 0.94,
    "diseases": [
      "Apple Scab",
      "Apple Black rot",
      "Blueberry Healthy",
      ...
    ]
  }
  ```

## 🧠 Model Details

- **Architecture**: Convolutional Neural Network (CNN)
- **Framework**: TensorFlow/Keras
- **Input Size**: 224×224 RGB images
- **Output Classes**: 39 disease classes + healthy plant
- **Accuracy**: ~94% on validation dataset
- **Model Size**: 
  - Full (.h5): ~50MB
  - Optimized (.tflite): ~15MB
- **Preprocessing**: 
  - Image normalization (0-1 scale)
  - Resize to 224×224
  - RGB format

### Diseases Detected
The model can detect 39+ plant diseases including:
- Apple diseases (Scab, Black rot, Cedar apple rust, etc.)
- Blueberry health status
- Cherry diseases
- Corn diseases
- Grape diseases
- And more...

## 🔐 Authentication

The app uses Firebase for user authentication:

### Email/Password Authentication
1. User enters email and password
2. Firebase validates credentials
3. Session token returned
4. Auto-login on app restart

### Google Sign-In
1. User clicks "Sign in with Google"
2. Google OAuth 2.0 flow
3. Firebase receives Google token
4. User profile created/updated

### Session Management
- Tokens stored securely in device keystore
- Auto-refresh before expiration
- Logout clears all local data

Firebase configuration files:
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)

## 📷 Scan History

All plant disease detections are stored locally with:
- 📸 **Original Image**: Full resolution plant photo
- 🎯 **Prediction**: Disease name and class ID
- 📊 **Confidence**: Prediction confidence score (0-1)
- ⏰ **Timestamp**: Date and time of detection
- 📝 **Notes**: Optional user notes about the plant
- 🌍 **Location**: GPS coordinates (if enabled)

Data persisted in SQLite database on device:
```sql
CREATE TABLE scan_history (
  id INTEGER PRIMARY KEY,
  image_path TEXT,
  disease TEXT,
  confidence REAL,
  timestamp TEXT,
  notes TEXT,
  user_id TEXT
);
```

## 🎨 UI/UX Design

### Color Scheme
- **Primary**: Deep green (#1B4332) - Nature-inspired
- **Secondary**: Light green (#52B788)
- **Dark Background**: #0B0E0C
- **Accent**: #FFB703

### Typography
- **Display**: Space Mono (monospace, technical feel)
- **Body**: Sora (modern, readable sans-serif)
- **Font Size**: 14-16px for readability outdoors

### Features
- ✅ Dark mode optimized for outdoor sunlight
- ✅ Large touch targets (48px minimum)
- ✅ High contrast for accessibility
- ✅ Intuitive navigation flow
- ✅ Fast scanning interface

## 📊 Deployment

### Backend (Railway.app)

```bash
# 1. Push code to GitHub
git push origin main

# 2. Connect Railway to GitHub
# - Go to railway.app
# - New Project → GitHub Repo
# - Select agrovision
# - Configure environment variables

# 3. Deploy
# - Railway auto-deploys on push
# - Access at: https://agrovision-api.railway.app

# 4. Monitor logs
# - Railway dashboard shows live logs
# - Check /health endpoint regularly
```

### Frontend (Mobile App)

**Android**:
```bash
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
# Size: ~50-60MB
# Can upload to Google Play Store
```

**iOS**:
```bash
flutter build ios --release

# Follow Xcode build steps
# Archive for App Store submission
```

## 🐛 Troubleshooting

### Model Loading Issues
```
Error: "No model loaded"
Solution: Check .tflite file exists in backend/models/
         Verify file permissions
         Check TensorFlow Lite runtime version
```

### Backend Connection
```
Error: "Failed to connect to API"
Solution: Check Firebase URL in Flutter config
         Verify CORS settings in Flask app
         Test with curl: curl https://agrovision-api.railway.app/health
         Check device network connectivity
```

### Firebase Authentication
```
Error: "Firebase not initialized"
Solution: Verify google-services.json in android/app/
         Check GoogleService-Info.plist in ios/Runner/
         Verify Firebase project ID matches config
         Enable Google Sign-In in Firebase console
```

### Image Processing
```
Error: "Invalid image format"
Solution: Ensure image is JPG/PNG
         Check image dimensions (should resize to 224×224)
         Verify RGB format (not RGBA)
         Check file size (<5MB recommended)
```

## 📈 Future Enhancements

- [ ] Multi-plant detection (multiple plants in one image)
- [ ] Offline mode with cached model
- [ ] Fertilizer recommendations based on soil analysis
- [ ] Weather-based disease prediction alerts
- [ ] Community reporting and disease tracking
- [ ] Integration with agricultural extension services
- [ ] Crop yield prediction
- [ ] Pest detection and identification
- [ ] Real-time crop monitoring dashboard
- [ ] Export reports as PDF

## 🤝 Contributing

Contributions welcome! Here's how:

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-feature`)
5. **Open** Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Author

**Prakhar Garg**
- 🎓 B.Tech CSE (Data Science & AI) - SRM University, Sonepat
- 📍 Location: Prayagraj, Uttar Pradesh
- 🔗 [GitHub](https://github.com/Prakhar3114)
- 💼 [LinkedIn](https://linkedin.com/in/prakhar-garg)
- 📧 Email: prakhar.garg@example.com

## 🙏 Acknowledgments

- TensorFlow/Keras for machine learning framework
- Firebase for authentication and cloud services
- Flutter team for amazing mobile framework
- Railway.app for reliable cloud hosting
- Open-source community for inspiration

## 📞 Support & Issues

For bugs, features, or questions:
1. **GitHub Issues**: Open an issue on repository
2. **Provide Details**:
   - Device/OS information
   - Error messages and logs
   - Steps to reproduce
   - Screenshots (if applicable)

## 🔗 Quick Links

- **Live API**: https://agrovision-api.railway.app
- **GitHub**: https://github.com/Prakhar3114/AgroVision
- **Firebase Console**: https://console.firebase.google.com
- **Railway Dashboard**: https://railway.app/dashboard

---

**Made with ❤️ for farmers and agriculture professionals worldwide**

*Last Updated: April 2024 | Version 1.0*
