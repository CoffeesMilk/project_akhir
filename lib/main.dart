import 'package:flutter/material.dart';
import 'package:project_akhir/pages/loginpage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir/models/user.dart';
import 'package:project_akhir/models/boxes.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(userAdapter());
  await Hive.openBox(HiveBoxex.user);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAMALI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: loginpage(),
    );
  }
}
