<div align="center">

# 💪 KinetiQ

### *Your AI Coach. Every Rep. Every Move.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen)](https://flutter.dev/multi-platform)
[![Track](https://img.shields.io/badge/Microsoft%20Agents%20League-Creative%20Apps%20Track-0078D4?logo=microsoft)](https://aka.ms/AgentsLeague)
[![Built with Copilot](https://img.shields.io/badge/Built%20with-GitHub%20Copilot-000000?logo=github)](https://github.com/features/copilot)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**KinetiQ** is an AI-powered fitness coach that uses your smartphone's front camera to detect movement, correct exercise form in real time, automatically count reps, and plan personalized workouts — all powered by on-device AI.

[📱 Try the Web Demo](#) · [📺 Watch Demo Video](#) · [📋 Hackathon Submission](#)

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🗓️ **AI Workout Planner** | Generates personalized weekly plans based on your goals, fitness level, and available equipment |
| 📷 **Real-Time Pose Detection** | MediaPipe tracks 33 body keypoints via your front camera — runs fully on-device |
| ✅ **Live Form Correction** | Joint angles are analyzed per-exercise and scored 0–100, with color-coded skeleton overlay |
| 🔢 **Automatic Rep Counter** | State-machine algorithm detects full movement cycles and counts reps — including partial rep detection |
| 🗣️ **Voice Coach** | Multilingual voice cues delivered in real time ("Lower your hips", "Keep your back straight") |
| 📊 **Progress Dashboard** | Session history, form score trends, personal records, and muscle group heatmap |

---

## 🎯 Microsoft Agents League Hackathon

> **Track**: Creative Apps — Built using GitHub Copilot
> **Event**: Microsoft AI Skills Fest 2026

KinetiQ was developed with **GitHub Copilot** as the primary AI-assisted development tool, accelerating everything from boilerplate scaffolding to complex pose detection logic and form-correction algorithms.

### How AI Agents Power KinetiQ

```
┌─────────────────────────────────────────────────────┐
│                   KinetiQ AI Agents                  │
├─────────────────────────────────────────────────────┤
│  🧠 Workout Planner Agent                            │
│     └─ Generates personalized 4-week programs        │
│        via Gemini API based on user profile          │
│                                                      │
│  👁️  Vision Coach Agent                              │
│     └─ MediaPipe pose estimation + joint angle       │
│        analysis + form rule evaluation               │
│                                                      │
│  🔢 Rep Counter Agent                                │
│     └─ State machine tracks movement cycles          │
│        per-exercise with partial rep detection       │
│                                                      │
│  🗣️  Voice Coach Agent                               │
│     └─ Throttled, multilingual TTS corrections       │
│        delivered in real time                        │
└─────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Android + iOS + Web) |
| **Pose Detection (Mobile)** | MediaPipe via `google_mlkit_pose_detection` |
| **Pose Detection (Web)** | MediaPipe JS SDK via `dart:js_interop` |
| **AI Workout Planning** | Gemini API (`google_generative_ai`) |
| **State Management** | Riverpod |
| **Local Database** | Drift (SQLite) |
| **Backend & Auth** | Firebase (Auth + Firestore) |
| **Voice Coach** | flutter_tts (multilingual) |
| **Navigation** | go_router |
| **Dev Assistant** | GitHub Copilot |

---

## 🏋️ Supported Exercises

<table>
<tr><th>Bodyweight</th><th>Dumbbell</th></tr>
<tr><td>

- Squat
- Push-up
- Lunge
- Plank (hold timer)
- Burpee
- Mountain Climber
- Jump Squat
- Tricep Dip
- Glute Bridge
- Superman

</td><td>

- Bicep Curl
- Shoulder Press
- Lateral Raise
- Bent-over Row
- Romanian Deadlift
- Goblet Squat
- Chest Fly
- Tricep Extension

</td></tr>
</table>

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install)
- [Gemini API Key](https://aistudio.google.com/) (free tier available)
- Android Studio or Xcode for mobile targets

### Installation

```bash
# Clone the repo
git clone https://github.com/alate-jane/KinetiQ.git
cd KinetiQ

# Install dependencies
flutter pub get

# Add your Gemini API key
# Create lib/core/config/secrets.dart (see secrets.example.dart)

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

### Environment Setup

```dart
// lib/core/config/secrets.example.dart
// Copy this file to secrets.dart and fill in your keys
const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
```

> ⚠️ Never commit `secrets.dart` — it's in `.gitignore`

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/          # Design system (dark mode, colors, typography)
│   ├── router/         # go_router navigation
│   └── config/         # API keys, constants
│
├── features/
│   ├── onboarding/     # Goal setting, fitness quiz
│   ├── home/           # Dashboard, today's workout
│   ├── planner/        # AI workout plan generation
│   ├── workout_player/ # Camera + pose + rep counter + form
│   │   ├── pose/       # MediaPipe integration (mobile + web)
│   │   ├── rep_counter/# Rep detection state machine
│   │   └── form_scorer/# Per-exercise form rules
│   ├── exercise_library/ # Exercise definitions
│   └── progress/       # History, charts, heatmap
│
└── data/
    ├── models/         # Data classes
    ├── repositories/   # Data access layer
    ├── local/          # Drift DB
    └── remote/         # Gemini + Firebase clients
```

---

## 🗺️ Roadmap

- [x] Project scaffolding + design system
- [ ] Onboarding quiz + user profile
- [ ] AI workout plan generation (Gemini)
- [ ] Camera + MediaPipe skeleton overlay
- [ ] Automatic rep counter
- [ ] Form scoring + voice coach
- [ ] Progress dashboard
- [ ] Social / community features (future)

---

## 👥 Team

Built solo by **[@alate-jane](https://github.com/alate-jane)** for the **Microsoft Agents League Hackathon 2026** using GitHub Copilot.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

Made with 💪 + 🤖 for the **Microsoft AI Skills Fest 2026**

</div>
