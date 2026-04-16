import 'package:flutter/material.dart';
import 'modules/home/presentation/view/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Championship Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF92A8D1)), // Azul Serenity
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
