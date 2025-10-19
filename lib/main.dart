import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_menu_screen.dart';
import 'services/audio_manager.dart';

/// Mısır Macerası - Hayatta Kalma Oyunu
/// Flutter ve Flame motorunu kullanarak geliştirilmiştir
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock screen orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Hide system UI (full screen game experience)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // Initialize audio manager asynchronously (don't block app start)
  AudioManager().initialize().then((_) {
    print('✅ Audio initialized successfully');
  }).catchError((e) {
    print('⚠️ Audio initialization failed: $e');
    print('⚠️ Game will continue without audio');
  });
  
  runApp(const EgyptSurvivalApp());
}

class EgyptSurvivalApp extends StatelessWidget {
  const EgyptSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egypt Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const MainMenuScreen(),
    );
  }
}
