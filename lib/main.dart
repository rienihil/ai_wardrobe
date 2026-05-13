import 'package:ai_wardrobe/providers/theme_provider.dart';
import 'package:ai_wardrobe/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(
      ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const AIWardrobeApp()
      )
  );
}

class AIWardrobeApp extends StatelessWidget {
  const AIWardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "AI Wardrobe",
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}