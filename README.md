# AwareScroll AI + FocusLock 🛡️📱

> **A two-feature Android-native digital self-regulation platform.** Captures user intention before opening Instagram or starting deep work, compares intention with actual behavior, prompts empathetic reflection at divergence boundaries, and feeds a unified behavioral dataset for descriptive analytics.

[![CI](https://github.com/Krish-Makwana7/minor-project---awarescroll/actions/workflows/ci.yml/badge.svg)](https://github.com/Krish-Makwana7/minor-project---awarescroll/actions)
[![Python 3.12+](https://img.shields.io/badge/Python-3.12+-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-009688.svg)](https://fastapi.tiangolo.com)
[![Android](https://img.shields.io/badge/Android-10+_(API_29+)-3DDC84.svg)](https://developer.android.com/)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack_Compose-Material3-4285F4.svg)](https://developer.android.com/jetpack/compose)

---

## 🎯 Product Overview

Existing screen-time apps rely on blunt instruments: hard lockouts that trigger user reactance or passive weekly summaries that provide no actionable insight.

**AwareScroll AI + FocusLock** changes this by closing the **Intention → Action → Divergence → Reflection → Data** loop:

1. **AwareScroll AI**: Before launching Instagram, users specify intended duration and purpose. If usage overruns, an empathetic reflection modal prompts awareness rather than a hard crash.
2. **FocusLock**: Protects dedicated focus blocks with soft-blocking via Android AccessibilityService, logging early interruptions and root causes (e.g. boredom, notifications, fatigue).
3. **Behavioral Intelligence Engine**: Consolidates both session types into a unified relational database, computing overrun rates, continuation rates, and focus completion metrics.

---

## 📁 Repository Structure

```
awarescroll-focuslock/
├── awarescroll-demo.apk             # Compiled Demo APK for Android devices / emulators
├── build-apk.ps1                    # One-click script to rebuild the Android APK
├── start-demo.ps1                   # One-click cross-device web launcher
│
├── web/                             # Cross-Platform Application (Android, iOS & Web)
│   ├── android/                     # Native Android Gradle Project (Capacitor)
│   ├── ios/                         # Native iOS Xcode Project (Capacitor)
│   ├── src/
│   │   ├── components/              # Device frame, Goals, Intention, AwareScroll, FocusLock, Insights, Dashboard
│   │   ├── services/                # Local storage, ML predictor engine, Cross-device Broadcast sync
│   │   └── types.ts
│   └── package.json
│
├── mobile/                          # Android Native Client (Kotlin, Jetpack Compose)
│   ├── app/src/main/java/com/awarescroll/
│   │   ├── ui/                      # Jetpack Compose Screens (Goals, Intention, Reflection, Focus, Insights)
│   │   ├── data/                    # Room Database (offline-first), Retrofit DTOs, Repository
│   │   ├── services/                # UsageMonitorService & FocusLockAccessibilityService
│   │   └── sync/                    # WorkManager SyncWorker for periodic backend synchronization
│   └── build.gradle.kts
│
├── backend/                         # FastAPI Backend Service (Python 3.12+)
│   ├── app/
│   │   ├── api/routes/              # Auth, Goals, Intentions, Usage, Focus, Feedback, Insights, Predictions
│   │   ├── models/                  # SQLAlchemy 2.0 ORM Models (11 tables)
│   │   ├── schemas/                 # Pydantic v2 schemas
│   │   ├── services/                # Business logic
│   │   └── celery_app.py            # Nightly aggregations & scheduled tasks
│   ├── alembic/                     # Database migrations
│   ├── tests/                       # Pytest test suite (6 passing integration tests)
│   └── pyproject.toml
│
├── data-science/                    # Behavioral Intelligence Engine
│   ├── pipelines/                   # Feature engineering, descriptive analytics, model training
│   ├── notebooks/                   # Exploratory analysis
│   └── models/                      # Saved trained models (Overrun: AUC 0.815, Interruption: AUC 0.772)
│
├── infra/                           # Infrastructure & Deployment
│   ├── docker-compose.yml           # Local Postgres 16 + Redis 7 + FastAPI + Celery
│   ├── Dockerfile.backend           # Production Python container image
│   └── github-actions/ci.yml        # Continuous Integration pipeline
│
└── docs/                            # Architectural & Specification Documentation
    └── architecture.md              # Technical system design & ER diagram
```

---

## 🛠️ Quick Start

### 0. Cross-Device Interactive Demo (Instant Setup — Any Device)

Run the cross-device demo to experience the complete AwareScroll AI + FocusLock platform across any desktop browser, laptop, tablet, iPhone, or Android device:

```bash
# Using PowerShell launcher:
.\start-demo.ps1

# Or using npm:
cd web
npm install
npm run dev -- --host
```
Open [http://localhost:5173](http://localhost:5173) in your browser. You can also open the Network URL printed in your terminal on your physical smartphone or tablet over local Wi-Fi to test cross-device synchronization live!

- **Command Center Mode**: Dual-pane view with phone simulator on left and real-time behavioral intelligence telemetry on right.
- **Phone / Tablet Mode**: Realistic device mockups for project evaluation presentations.
- **Mobile Native Mode**: Automatically adapts if opened directly on an iPhone or Android phone.

### 0.1 Mobile Demo APK (Android) & iOS Project

A cross-platform mobile application targeting **both Android and iOS** is fully prepared:

1. **Pre-Compiled Android Demo APK**:
   - Location: [`awarescroll-demo.apk`](file:///c:/minor-project---awarescroll-main/awarescroll-demo.apk) (approx 4.2 MB)
   - Install directly onto an Android phone or emulator:
     ```bash
     adb install awarescroll-demo.apk
     ```
   - Or transfer `awarescroll-demo.apk` to your Android device via USB/drive and tap to install.

2. **iOS Project (Xcode)**:
   - Location: [`web/ios/App/App.xcodeproj`](file:///c:/minor-project---awarescroll-main/web/ios/App)
   - Open in Xcode on macOS:
     ```bash
     cd web
     npx cap open ios
     ```
   - Select your target iPhone/iPad device or iOS Simulator in Xcode and press **Run (Cmd + R)**.

3. **Rebuild the Android APK Anytime**:
   ```powershell
   .\build-apk.ps1
   ```

### 1. Backend Setup (Local / Docker)

**Using Docker Compose:**
```bash
cd infra
docker compose up -d
```
The FastAPI documentation will be available at [http://localhost:8000/docs](http://localhost:8000/docs).

**Using Local Python Virtual Environment:**
```bash
cd backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/macOS:
source .venv/bin/activate

pip install -e ".[dev]"
pytest -v tests/
uvicorn app.main:app --reload --port 8000
```

### 2. Android App

1. Open Android Studio (Ladybug / Hedgehog or newer).
2. Open directory `mobile/`.
3. Sync Gradle and build project (`Build -> Make Project`).
4. Run on an Android emulator or device with Android 10+ (API 29+).
5. Grant required permissions: **Usage Access** & **Accessibility Service** when prompted on first launch.

### 3. Data Science Pipelines

```bash
cd data-science
pip install -r requirements.txt

# Run feature engineering & synthetic dataset generation
python pipelines/feature_engineering.py

# Train models
python pipelines/train_overrun_model.py
python pipelines/train_interruption_model.py
```

---

## 🔄 Development & Syncing

To easily commit and push changes directly from Windows:
```powershell
.\sync.ps1 "feat: your commit message"
```
Or run `git commit` as usual — the pre-configured post-commit hook will automatically push changes to `main`.

---

## 📄 License
This project is licensed under the MIT License.
