import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:vi/provider/theme_provider.dart';
import 'package:vi/screens/home_screen.dart';
import 'package:vi/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService().database; // Init before run the app

  // Init background audio
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.viplayer.audio',
    androidNotificationChannelName: 'Vi Player',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  runApp(
    ChangeNotifierProvider(create: (_) => ThemeProvider(), child: const App()),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // App Material Design
      title: 'Vi Player',
      theme: context.watch<ThemeProvider>().initTheme,
      home: const HomeScreen(),
    );
  }
}
