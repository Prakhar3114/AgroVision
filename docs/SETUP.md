# 📋 Setup & Installation Guide

## Prerequisites

### System Requirements
- **OS**: Windows 10+, macOS 10.15+, or Ubuntu 18.04+
- **RAM**: 4GB minimum (8GB recommended)
- **Storage**: 5GB free space

### Required Software
- **Python**: 3.9 or higher
- **Flutter**: 3.0 or higher
- **Git**: Latest version
- **Git LFS**: For model files
- **Android SDK**: For Android development (optional)
- **Xcode**: For iOS development (optional)

---

## 🔧 Backend Setup

### 1. Install Python & Git LFS

**Windows:**
```bash
# Check Python version
python --version  # Should be 3.9+

# Install Git LFS
# Download from: https://git-lfs.github.com/
# Or use Chocolatey:
choco install git-lfs
git lfs install
```

**macOS:**
```bash
# Install Python (if needed)
brew install python@3.9

# Install Git LFS
brew install git-lfs
git lfs install
```

**Linux (Ubuntu):**
```bash
sudo apt update
sudo apt install python3.9 python3.9-venv python3-pip
sudo apt install git-lfs
git lfs install
```

### 2. Clone Repository

```bash
# Clone the repository
git clone https://github.com/Prakhar3114/AgroVision.git
cd AgroVision
```

### 3. Create Virtual Environment

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3.9 -m venv venv
source venv/bin/activate
```

You should see `(venv)` at start of terminal line.

### 4. Install Python Dependencies

```bash
# Navigate to backend
cd backend

# Install requirements
pip install -r requirements.txt

# Verify installation
pip list | grep tensorflow
pip list | grep flask
```

**Key packages:**
- Flask: REST API framework
- TensorFlow: Machine learning
- TensorFlow Lite: Model inference
- Pillow: Image processing
- NumPy: Numerical computing

### 5. Download Model Files

The TensorFlow Lite model is tracked with Git LFS:

```bash
# Model should auto-download with git clone
# Verify model exists:
ls -la backend/plant_disease_model.tflite

# If missing, download manually:
git lfs pull
```

File should be ~15MB.

### 6. Run Backend Server

```bash
# In backend directory
python app.py

# Output should show:
# * Running on http://127.0.0.1:5000
```

Test the API:
```bash
# In new terminal
curl http://localhost:5000/health

# Should return:
# {"status":"ok","model_loaded":true,"api_version":"1.0"}
```

---

## 📱 Frontend Setup

### 1. Install Flutter

**Windows:**
```bash
# Download Flutter from: https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add to PATH

flutter --version  # Verify installation
```

**macOS:**
```bash
# Using Homebrew
brew install flutter

# Or download manually
flutter --version
```

**Linux (Ubuntu):**
```bash
# Download
cd ~/development
tar xf ~/Downloads/flutter_linux_3.0.0-stable.tar.xz

# Add to PATH
export PATH="$PATH:$HOME/development/flutter/bin"

flutter --version
```

### 2. Run Flutter Doctor

```bash
flutter doctor

# Should show:
# [✓] Flutter
# [✓] Android toolchain (optional)
# [✓] Xcode (optional)
# [✓] VS Code
```

### 3. Get Dependencies

```bash
# In project root
flutter pub get

# Output shows:
# Running "flutter pub get" in agrovision...
# Got dependencies! (X packages)
```

### 4. Configure Firebase

#### Android Configuration
1. Download `google-services.json` from Firebase Console
2. Place at: `android/app/google-services.json`

#### iOS Configuration
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place at: `ios/Runner/GoogleService-Info.plist`
3. Add to Xcode project (if needed)

### 5. Run App

```bash
# List connected devices
flutter devices

# Run on Android
flutter run -d <device-id>

# Run on iOS
flutter run -d <device-id>

# Run on all devices
flutter run
```

### 6. Build Release APK

```bash
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
# Size: ~50-60MB
```

---

## 🗄️ Database Setup

### SQLite Configuration

SQLite database is created automatically on first app launch.

**Location:**
- **Android**: `/data/data/com.example.agrovision/databases/agrovision.db`
- **iOS**: Application Documents folder

**Manual initialization:**
```bash
# In project root
sqlite3 agrovision.db

# Create tables (if needed)
.read backend/schema.sql
```

### Database Schema

```sql
CREATE TABLE scan_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,
  disease TEXT NOT NULL,
  confidence REAL NOT NULL,
  timestamp TEXT NOT NULL,
  notes TEXT,
  user_id TEXT,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE,
  name TEXT,
  created_at TEXT,
  last_login TEXT
);
```

---

## 🔐 Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project: `agrovision`
3. Enable Google Analytics (optional)

### 2. Enable Authentication

1. **Authentication** → Sign-in methods
2. Enable:
   - Email/Password ✅
   - Google ✅

### 3. Create Firestore Database

1. **Firestore Database** → Create database
2. Start in **test mode** (development)
3. Select region: `us-central1`

### 4. Create Collections

```
firestore/
├── users/
│   └── {userId}/
│       ├── email
│       ├── name
│       ├── created_at
│       └── profile_pic
└── scans/
    └── {userId}/
        └── {scanId}/
            ├── image_url
            ├── disease
            ├── confidence
            └── timestamp
```

### 5. Configure App

Android (`android/app/google-services.json`):
```json
{
  "project_info": {
    "project_id": "agrovision-xxxxx"
  },
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.example.agrovision"
        }
      }
    }
  ]
}
```

---

## 🚀 Deployment

### Backend Deployment (Railway.app)

```bash
# 1. Login to Railway
railway login

# 2. Create Railway project
railway init

# 3. Add environment variables
railway variable set FLASK_ENV production
railway variable set FLASK_APP app.py

# 4. Deploy
railway up

# 5. Get URL
railway variables RAILWAY_URL
```

### Mobile App Distribution

**Google Play Store:**
```bash
# 1. Create Google Play account
# 2. Create signed APK
flutter build apk --release --split-per-abi

# 3. Upload to Play Store Console
# 4. Fill store listing, screenshots, description
# 5. Submit for review
```

**iOS App Store:**
```bash
# 1. Create Apple Developer account
# 2. Build for App Store
flutter build ios --release

# 3. In Xcode:
# Archive → Distribute → App Store
# 4. Submit for review
```

---

## ✅ Verification Checklist

### Backend
- [ ] Python 3.9+ installed
- [ ] Virtual environment activated
- [ ] Dependencies installed (`pip list`)
- [ ] Model file present (15MB .tflite)
- [ ] Server running on localhost:5000
- [ ] `/health` endpoint returns 200

### Frontend
- [ ] Flutter installed
- [ ] All packages downloaded (`flutter pub get`)
- [ ] Firebase configured
- [ ] Android/iOS SDK installed
- [ ] Device connected or emulator running
- [ ] App compiles without errors

### Database
- [ ] SQLite database created
- [ ] Tables initialized
- [ ] Test insert/query works

### Deployment
- [ ] GitHub repository synced
- [ ] Railway account created
- [ ] Environment variables set
- [ ] Backend API accessible online
- [ ] Mobile app can connect to backend

---

## 🐛 Troubleshooting

### Python Issues
```bash
# ModuleNotFoundError
pip install -r requirements.txt --upgrade

# Python version mismatch
python --version  # Should be 3.9+
python3.9 -m venv venv  # Explicitly specify version
```

### Flutter Issues
```bash
# Pub get fails
flutter clean
flutter pub get

# Build fails
flutter clean
flutter pub cache repair
flutter build apk
```

### Firebase Issues
```bash
# Google sign-in fails
# - Check google-services.json
# - Verify app package name matches Firebase
# - Check SHA1 fingerprint in Firebase

# Firestore connection fails
# - Check Firebase security rules
# - Verify internet connectivity
# - Check Firebase project ID
```

### Backend Connection
```bash
# Cannot reach API from app
# - Check API URL in app config
# - Test with: curl https://agrovision-api.railway.app/health
# - Check CORS settings in Flask
# - Verify device network access
```

---

## 📖 Next Steps

1. Read [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
2. Check [API.md](./API.md) for detailed API documentation
3. See [MODELS.md](./MODELS.md) for ML model information
4. Deploy to production following [deployment guide](#deployment)

---

**Need help?** Open an issue on [GitHub](https://github.com/Prakhar3114/AgroVision)
