import 'package:drpechayapp/pages/Navigation.dart';
import 'package:flutter/material.dart';



void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pechay Doctor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 150, 235, 14)),
        useMaterial3: true,
      ),
      home: const Navigation(),
    );
  } 
}