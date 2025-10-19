# 🏜️ Egypt Survival - Tap to Survive Arcade Game

An Egyptian-themed tap-to-survive arcade game developed using the Flutter and Flame engines. A rich mobile gaming experience enhanced with a modern UI, dynamic difficulty levels, and a comprehensive sound system.

## 🎮 Game Features

### Key Features
- **🏺 Egyptian Theme**: 
  - Dynamic sand dunes and hieroglyph-patterned background
  - Player character shaped like the Eye of Horus
  - Obstacles shaped like Egyptian obelisks
  
- **👆 Touch Controls**: 
  - Jump by tapping the screen
  - Simple and intuitive control system
  
- **🎚️ 5 Difficulty Levels**: 
  - **Novice**: Relaxed pace for beginners
  - **Explorer**: Balanced difficulty for intermediate players
  - **Adventurer**: Fast-paced for experienced players
  - **Master**: Challenging experience for advanced players
  - **Pharaoh**: Extreme difficulty for only the best

- **🔊 Comprehensive Sound System**: 
  - Continuous background music
  - Jump sound effect
  - Game Over sound effect
  - Menu selection sound effect
  - Platform-based optimizations (iOS/Android/Web)

- **🏆 Score and High Score System**: 
  - Separate high scores for each difficulty level
  - Real-time score tracking
  - Session-based high score saving
  
- **⚡ Dynamic Difficulty**: 
  - Obstacles speed up as the game progresses
  - Obstacle spawn frequency increases
  - Each difficulty level customized with different parameters

- **🎯 Smart Obstacle System**: 
  - Obstacles come from different heights (low, medium, high)
  - Random spawn positions
  - Speeds adjusted according to difficulty level

- **📱 60 FPS Performance**: 
  - Smooth gaming experience
  - Optimized rendering system
  - Seamless operation on all devices

## 🚀 Installation and Execution

### Requirements

- Flutter SDK (3.9.2 or higher recommended)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code (recommended)
- Android device/emulator or iOS device/simulator

### Installation Steps

1. **Download or clone the project**

```bash
cd surver_game
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Ensure sound files are in place**

```
assets/sounds/
├── background_music.mp3
├── jump.mp3
├── game_over.mp3
└── menu-selection-102220.mp3
```

4. **Run the application**

```bash
flutter run
```

or press the Run/Debug button (F5) in your IDE.

## 🎯 How to Play?

### Main Menu
1. Background music starts automatically when the app opens
2. Choose one of 5 difficulty levels:
   - 🟢 **NOVICE**: Slow pace, wide spawn range
   - 🔵 **EXPLORER**: Medium speed, balanced difficulty
   - 🟡 **ADVENTURER**: Fast pace, frequent spawns
   - 🟠 **MASTER**: Very fast, challenging
   - 🔴 **PHARAOH**: Maximum speed, extreme difficulty
3. Press the “START GAME” button

### In-Game
- **Jump**: Tap anywhere on the screen
- **Objective**: Avoid incoming obelisks
- **Score**: +1 point for each obstacle avoided
- **High Score**: Your highest score for each difficulty is displayed on the screen
- **Back**: Return to the main menu using the back button in the upper left corner

### Game Over
- Your current score and high score are displayed
- **PLAY AGAIN**: Restart at the same difficulty level
- **MAIN MENU**: Return to the main menu and select a different difficulty

## 📁 Project Structure

```
surver_game/
├── lib/
│   ├── main.dart                          # Main entry point, system settings
│   ├── screens/
│   │   ├── main_menu_screen.dart          # Main menu, difficulty selection
│   │   ├── game_screen.dart               # Game container
│   │   └── game_over_screen.dart          # Game Over screen
│   ├── game/
│   │   ├── egypt_survival_game.dart       # Main game logic (Flame)
│   │   ├── background_component.dart      # Dynamic background
│   │   └── components/
│   │       ├── player.dart                # Player component (Horus Eye)
│   │       └── spike.dart                 # Obstacle component (Obelisk)
│   └── services/
│       └── audio_manager.dart             # Audio management service (Singleton)
├── assets/
│   └── sounds/                            # Sound files
│       ├── background_music.mp3
│       ├── jump.mp3
│       ├── game_over.mp3
│       └── menu-selection-102220.mp3
├── android/                               # Android platform files
├── ios/                                   # iOS platform files
├── web/                                   # Web platform files
├── pubspec.yaml                           # Package dependencies
└── README.md                              # This file
```

## 🔧 Technical Details

### Packages Used

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0              # 2D game engine
  audioplayers: ^6.0.0        # Audio management

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0       # Code quality
```

### Architecture and Design

#### 1. **Main Game Engine** (`egypt_survival_game.dart`)
- Main game loop based on `FlameGame`
- Collision detection (distance-based collision)
- Dynamic spawn system
- Score and high score management
- Difficulty

Translated with DeepL.com (free version)