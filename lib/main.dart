import 'package:flutter/material.dart';
import 'screens/folders_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FoldersScreen(),
    );
  }
}
