import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nyore/core/navigation/app_routes.dart';
import 'package:nyore/core/navigation/routes.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.root,
      routes: appRoutes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Halaman tidak ditemukan'),
            ),
          ),
        );
      },
    );
  }
}
