<div align="center">

# 💪 KinetiQ

### *Your AI Coach. Every Rep. Every Move.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen)](https://flutter.dev/multi-platform)
[![Track](https://img.shields.io/badge/Microsoft%20Agents%20League-Creative%20Apps%20Track-0078D4?logo=microsoft)](https://aka.ms/AgentsLeague)
[![Built with Copilot](https://img.shields.io/badge/Built%20with-GitHub%20Copilot-000000?logo=github)](https://github.com/features/copilot)
[![Powered by Azure OpenAI](https://img.shields.io/badge/Powered%20by-Azure%20OpenAI-0078D4?logo=microsoftazure)](https://azure.microsoft.com/en-us/products/ai-services/openai-service)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**KinetiQ** is an AI-powered fitness coach that uses your smartphone's front camera to detect movement, correct exercise form in real time, automatically count reps, and plan personalized workouts — powered by **Azure OpenAI GPT-4o** and **MediaPipe**.

[📱 Try the Web Demo](#) · [📺 Watch Demo Video](#) · [📋 Hackathon Submission](#)

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🗓️ **AI Workout Planner** | Generates personalized 4-week plans via Azure OpenAI GPT-4o based on your goals, level & equipment |
| 📷 **Real-Time Pose Detection** | MediaPipe tracks 33 body keypoints via your front camera — runs fully on-device |
| ✅ **Live Form Correction** | Joint angles are analyzed per-exercise and scored 0–100, with color-coded skeleton overlay |
| 🔢 **Automatic Rep Counter** | State-machine algorithm detects full movement cycles and counts reps — including partial rep detection |
| 🗣️ **Voice Coach** | Multilingual voice cues delivered in real time ("Lower your hips", "Keep your back straight") |
| 📊 **Progress Dashboard** | Session history, form score trends, personal records, and muscle group heatmap |

---

## 🎯 Microsoft Agents League Hackathon

> **Track**: Creative Apps — Built using GitHub Copilot
> **Event**: Microsoft AI Skills Fest 2026

KinetiQ was developed with **GitHub Copilot** as the primary AI-assisted development tool and **Azure OpenAI GPT-4o** as the intelligent workout planning engine — both core Microsoft AI products.

### How AI Agents Power KinetiQ

```
┌─────────────────────────────────────────────────────┐
│                   KinetiQ AI Agents                  │
├─────────────────────────────────────────────────────┤
│  🧠 Workout Planner Agent                            │
│     └─ Azure OpenAI GPT-4o generates personalized   │
│        4-week progressive plans from user profile   │
│                                                      │
│  👁️  Vision Coach Agent                              │
│     └─ MediaPipe pose estimation + joint angle       │
│        analysis + per-exercise form rule evaluation  │
│                                                      │
│  🔢 Rep Counter Agent                                │
│     └─ State machine tracks full movement cycles     │
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
| **AI Workout Planning** | ⭐ Azure OpenAI GPT-4o (REST API) |
| **Dev Assistant** | ⭐ GitHub Copilot |
| **Pose Detection (Mobile)** | MediaPipe via `google_mlkit_pose_detection` |
| **Pose Detection (Web)** | MediaPipe JS SDK via `dart:js_interop` |
| **State Management** | Riverpod |
| **Local Storage** | SharedPreferences + Drift (SQLite) |
| **Voice Coach** | flutter_tts (multilingual) |
| **Navigation** | go_router |
| **HTTP Client** | `http` package (Azure OpenAI REST calls) |

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
- [Azure OpenAI resource](https://portal.azure.com) with a `gpt-4o` deployment
- Android Studio or Xcode for mobile targets (optional — web works out of the box)

### Installation

```bash
# Clone the repo
git clone https://github.com/alate-jane/KinetiQ.git
cd KinetiQ

# Install dependencies
flutter pub get
```

### Running with Azure OpenAI

Pass your Azure credentials via `--dart-define` (never hardcode keys!):

```bash
# Web
flutter run -d chrome \
  --dart-define=AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com \
  --dart-define=AZURE_OPENAI_KEY=YOUR_API_KEY \
  --dart-define=AZURE_OPENAI_DEPLOYMENT=gpt-4o

# Android
flutter run -d android \
  --dart-define=AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com \
  --dart-define=AZURE_OPENAI_KEY=YOUR_API_KEY \
  --dart-define=AZURE_OPENAI_DEPLOYMENT=gpt-4o
```

> 💡 **No Azure key?** The app includes a built-in demo plan so you can explore the full UI without any credentials.

> ⚠️ Never commit API keys — use `--dart-define` or a local `.env` file excluded by `.gitignore`

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/              # Design system: dark navy + electric mint palette, Inter font
│   ├── router/             # go_router with onboarding redirect logic
│   └── config/             # Azure OpenAI endpoint config (dart-define)
│
├── features/
│   ├── onboarding/         # ✅ 4-step animated quiz (goal, level, equipment, style)
│   │   ├── screens/
│   │   └── providers/      # Riverpod state for onboarding flow
│   ├── home/               # ✅ Dashboard + bottom nav + plan-aware workout card
│   ├── planner/            # ✅ AI workout plan generation + weekly calendar UI
│   │   ├── screens/        # Empty state, loading, plan view, exercise cards
│   │   ├── services/       # AzureOpenAIService (REST + prompt engineering)
│   │   └── providers/      # Riverpod state + local persistence
│   ├── workout_player/     # 🔄 Day 4: Camera + MediaPipe + rep counter + form
│   │   ├── pose/           # MediaPipe integration (mobile + web)
│   │   ├── rep_counter/    # Rep detection state machine
│   │   └── form_scorer/    # Per-exercise form rules
│   └── progress/           # 📅 Day 8: History, charts, heatmap
│
└── data/
    ├── models/             # ✅ UserProfile, WorkoutPlan, WorkoutDay, WorkoutExercise
    └── repositories/       # Data access layer
```

---

## 🗺️ Build Roadmap

| Day | Feature | Status |
|-----|---------|--------|
| 1 | Project setup + GitHub repo | ✅ Done |
| 2 | Design system + Onboarding quiz + Home dashboard | ✅ Done |
| 3 | Azure OpenAI workout planner + weekly calendar UI | ✅ Done |
| 4 | Camera + MediaPipe skeleton overlay (mobile & web) | 🔄 Next |
| 5 | Automatic rep counter (5 core exercises) | 📅 Planned |
| 6 | Form scoring + multilingual voice coach | 📅 Planned |
| 7 | Progress dashboard | 📅 Planned |
| 8 | Polish + demo video + submission | 📅 Planned |

---

## 👥 Team

Built solo by **[@alate-jane](https://github.com/alate-jane)** for the **Microsoft Agents League Hackathon 2026** using GitHub Copilot + Azure OpenAI.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

Made with 💪 + 🤖 for the **Microsoft AI Skills Fest 2026**

⭐ **Powered by Azure OpenAI** · 🤖 **Built with GitHub Copilot** · 📱 **Flutter**

</div>
