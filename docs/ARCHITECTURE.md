# 🏗️ System Architecture

## High-Level Overview

AgroVision is a distributed system combining mobile client, REST API backend, and cloud services.

```
┌─────────────────────────────────────────────────────────────┐
│                    User's Mobile Device                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Flutter Mobile App (Dark UI)                  │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │ UI Layer (Screens & Widgets)                     │ │ │
│  │  │ - Splash Screen                                  │ │ │
│  │  │ - Login Screen (Firebase Auth)                   │ │ │
│  │  │ - Home Screen (Camera + Scanner)                 │ │ │
│  │  │ - History Screen (Scan Results)                  │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │ Business Logic Layer (Services)                  │ │ │
│  │  │ - API Service (HTTP calls)                       │ │ │
│  │  │ - Auth Service (Firebase)                        │ │ │
│  │  │ - DB Service (SQLite)                            │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │ Data Layer                                       │ │ │
│  │  │ - SQLite (Local History)                         │ │ │
│  │  │ - Shared Preferences (Session)                   │ │ │
│  │  │ - File Storage (Images)                          │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                   │
│                    (REST API + Firebase)                      │
└───────────────────────────┼───────────────────────────────────┘
                            │
                    ┌───────┴──────┐
                    │              │
           ┌────────▼────────┐   ┌─▼────────────────┐
           │   Flask Backend │   │  Firebase Cloud  │
           │  (Railway.app)  │   │  - Authentication│
           │                 │   │  - Firestore DB  │
           └─────────────────┘   └──────────────────┘
                    │
           ┌────────▼────────────────┐
           │  ML Model (TensorFlow   │
           │  Lite CNN Classifier)   │
           │  - 224x224 Input        │
           │  - 39 Classes Output    │
           └─────────────────────────┘
```

---

## 📱 Frontend Architecture (Flutter)

### Layer Structure

#### 1. **UI Layer**
Handles all user interface and visual components.

**Screens:**
```
lib/screens/
├── splash_screen.dart       # App initialization
├── login_screen.dart        # Email/Google auth
├── home_screen.dart         # Main camera interface
└── history_screen.dart      # Scan history display
```

**Widgets:**
```
lib/widgets/
├── camera_widget.dart       # Camera capture UI
├── prediction_card.dart     # Disease result display
├── history_tile.dart        # History list item
└── loading_indicator.dart   # Loading states
```

#### 2. **Business Logic Layer**
Manages state and application logic.

**Services:**
```
lib/services/
├── api_service.dart         # Backend communication
├── auth_service.dart        # Firebase authentication
└── db_service.dart          # Local database operations
```

**Models:**
```
lib/models/
├── prediction_model.dart    # API response structure
├── scan_history_model.dart  # Database structure
└── user_model.dart          # User profile structure
```

#### 3. **Data Layer**
Persistent storage and caching.

**Storage Types:**
- **SQLite**: Scan history, user data
- **SharedPreferences**: Session tokens, user settings
- **FileSystem**: Images (path_provider)
- **Firebase**: User accounts, cloud data

### Data Flow

```
User Action (Camera) 
    ↓
Home Screen captures image
    ↓
Convert to Base64
    ↓
API Service → POST /predict
    ↓
Backend processes
    ↓
Returns JSON {disease, confidence, recommendations}
    ↓
Parse response → Create PredictionModel
    ↓
DB Service saves to SQLite
    ↓
UI updates with results
    ↓
Display disease info + history
```

---

## 🔌 Backend Architecture (Flask)

### API Structure

```
Flask App (app.py)
├── Route: GET /health
│   └── Returns API status
├── Route: GET /model/info
│   └── Returns model metadata
├── Route: POST /predict
│   ├── Receives base64 image
│   ├── Preprocess image
│   ├── Run TensorFlow Lite inference
│   ├── Post-process results
│   └── Return JSON response
└── Middleware
    ├── CORS handling
    ├── Request validation
    └── Error handling
```

### ML Pipeline

```
Input Image (Base64)
    ↓
Decode to numpy array
    ↓
Resize to 224×224 (bilinear interpolation)
    ↓
Normalize (0-1 range)
    ↓
TensorFlow Lite Interpreter
    ├── Input tensor: [1, 224, 224, 3]
    └── Output tensor: [1, 39] (softmax probabilities)
    ↓
Post-processing:
├── Get top prediction (argmax)
├── Get confidence score
└── Map class_id to disease name
    ↓
Generate recommendations (rule-based)
    ↓
Return JSON
```

### Model Structure

**CNN Architecture:**
```
Input: 224×224×3 RGB image
    ↓
Conv2D(32, 3×3) + ReLU + BatchNorm
    ↓
MaxPool2D(2×2)
    ↓
Conv2D(64, 3×3) + ReLU + BatchNorm
    ↓
MaxPool2D(2×2)
    ↓
Conv2D(128, 3×3) + ReLU + BatchNorm
    ↓
GlobalAveragePooling2D
    ↓
Dense(256) + ReLU + Dropout(0.5)
    ↓
Dense(39) + Softmax
    ↓
Output: 39 disease classes
```

---

## 🔐 Authentication Flow

### Firebase Email/Password

```
User enters email + password
    ↓
Flutter: firebaseAuth.signInWithEmailAndPassword()
    ↓
Firebase validates credentials
    ↓
Returns ID token + refresh token
    ↓
Store in device keystore
    ↓
Set auth state to authenticated
    ↓
Navigate to home screen
```

### Google Sign-In

```
User clicks "Sign in with Google"
    ↓
Flutter: GoogleSignIn.signIn()
    ↓
Opens Google OAuth dialog
    ↓
User logs in with Google account
    ↓
Returns Google ID token
    ↓
Flutter: signInWithCredential(googleIdToken)
    ↓
Firebase creates user if new
    ↓
Returns session token
    ↓
Navigate to home screen
```

### Session Management

```
Login successful
    ↓
Store token in Keystore (Android) / Keychain (iOS)
    ↓
Store refresh token
    ↓
Set token expiration
    ↓
On app resume:
├── Check if token expired
├── If expired: refresh token
└── If valid: auto-login
    ↓
On logout:
└── Clear tokens + local data
```

---

## 💾 Database Schema

### SQLite Tables

#### scan_history
```sql
CREATE TABLE scan_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,           -- Local file path
  disease TEXT NOT NULL,              -- Predicted disease
  confidence REAL NOT NULL,           -- Confidence 0-1
  timestamp TEXT NOT NULL,            -- ISO 8601 format
  notes TEXT,                         -- User notes
  user_id TEXT NOT NULL,              -- Current user ID
  created_at TEXT NOT NULL,
  updated_at TEXT,
  FOREIGN KEY(user_id) REFERENCES users(id)
);
```

#### users
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,                -- Firebase UID
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  profile_pic TEXT,
  created_at TEXT NOT NULL,
  last_login TEXT,
  total_scans INTEGER DEFAULT 0
);
```

### Firestore Collections

```
firestore/
├── users/{userId}
│   ├── email: string
│   ├── name: string
│   ├── profile_pic: string
│   ├── created_at: timestamp
│   └── last_login: timestamp
│
└── scans/{userId}/scans/{scanId}
    ├── image_url: string (optional)
    ├── disease: string
    ├── confidence: number
    ├── timestamp: timestamp
    └── notes: string
```

---

## 🌐 API Communication

### Request Format

```
POST /predict
Content-Type: application/json

{
  "image": "base64_encoded_string_here...",
  "user_id": "firebase_user_id"
}
```

### Response Format (Success)

```json
{
  "status": "success",
  "disease": "Early Blight",
  "class_id": 5,
  "confidence": 0.9234,
  "recommendations": [
    "Apply fungicide spray",
    "Remove infected leaves",
    "Ensure good air circulation",
    "Water at base of plant"
  ],
  "info": {
    "disease_name": "Early Blight",
    "common_names": ["Early leaf spot", "Target spot"],
    "severity": "High",
    "treatment_cost": "Low to Medium"
  },
  "timestamp": "2024-04-15T10:30:00Z"
}
```

### Response Format (Error)

```json
{
  "status": "error",
  "error": "Invalid image format",
  "message": "Image must be JPG or PNG",
  "code": 400
}
```

---

## 🔄 Complete User Journey

### 1. Onboarding
```
User opens app
├── Splash screen (2 seconds)
├── Check if logged in
│   ├── Yes: Skip to home
│   └── No: Show login screen
└── User chooses:
    ├── Email signup/login
    └── Google sign-in
```

### 2. Main Workflow
```
Home screen displayed
├── User allows camera permission
├── Point camera at plant
├── Click capture button
├── Image preprocessing
├── Send to backend API
│   └── Flask processes with TensorFlow Lite
├── Receive prediction
├── Display disease info
├── Save to local history
└── Offer options:
    ├── Take another photo
    ├── View history
    └── Share results
```

### 3. History Management
```
User navigates to history
├── Query SQLite database
├── Display scan history
│   └── Most recent first
├── User selects scan
├── View details:
    ├── Image thumbnail
    ├── Disease + confidence
    ├── Timestamp
    └── Recommendations
└── Options:
    ├── Delete scan
    └── Add notes
```

---

## 📊 Performance Considerations

### Frontend Optimization
- **Image compression**: JPEG 85% quality
- **Lazy loading**: Images load only when visible
- **Caching**: API responses cached locally
- **State management**: Efficient rebuilds
- **Memory**: Images freed after transmission

### Backend Optimization
- **Model caching**: Load once at startup
- **Batch processing**: Ready for multiple requests
- **Image validation**: Reject invalid formats early
- **Response compression**: gzip enabled
- **Connection pooling**: Reuse connections

### Latency
- **Mobile network**: ~200-500ms for image capture + transfer
- **Backend inference**: ~1-2s for TensorFlow Lite
- **Total**: ~3-4s for complete prediction
- **Optimization**: Parallel requests possible

---

## 🔒 Security Architecture

### Data Protection
- **In Transit**: HTTPS/SSL encryption
- **At Rest**: Device keystore for tokens
- **Sensitive Data**: Never logged or cached unencrypted

### Authentication
- **Firebase**: Industry-standard authentication
- **Token Expiration**: Auto-refresh
- **Scope Limitation**: API keys restricted

### Privacy
- **Local Storage**: All user images stored locally only
- **No Cloud Upload**: Images not sent to Firebase
- **User Control**: Delete scans anytime
- **GDPR Compliant**: Data export/deletion available

---

## 📈 Scalability Design

### Horizontal Scaling
- **Backend**: Multiple Railway instances (auto-scaling)
- **Database**: Firebase handles scaling automatically
- **Storage**: Cloud storage ready for future image backups

### Load Distribution
- **API Gateway**: Railway handles routing
- **Database Replication**: Firebase manages redundancy
- **CDN Ready**: Images can be distributed via CDN

---

## 🔧 Technology Choices

| Component | Technology | Why Chosen |
|-----------|-----------|-----------|
| Mobile | Flutter | Cross-platform, fast, hot reload |
| Backend | Flask | Lightweight, Python ML integration |
| ML | TensorFlow Lite | Optimized for mobile inference |
| Database | SQLite + Firestore | Local + cloud redundancy |
| Auth | Firebase | Secure, scalable, OAuth ready |
| Hosting | Railway | Simple deployment, free tier |
| Language | Dart + Python | Type-safe, ML friendly |

---

## 🎯 Future Architecture Improvements

- [ ] GraphQL API (vs REST)
- [ ] Redis caching layer
- [ ] Kubernetes containerization
- [ ] Microservices separation
- [ ] WebSocket real-time updates
- [ ] ML model versioning system
- [ ] A/B testing framework

---

**Architecture v1.0** | Last updated: April 2024
