import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_vault/page/main_layout.dart';
import 'package:time_vault/services/TimerService.dart';

import 'data/db/app_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDb.instance.database;
  print("Database initialized: $db"); // Just to verify
  runApp(ChangeNotifierProvider(create: (_) => TimerService(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainLayout(),
      // home: Scaffold(
      //   appBar: AppBar(title: const Text('Hello World')),
      //   body: const Center(child: Text('Welcome')),
      // ),
    );
  }
}
