import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/content_provider.dart';
import 'providers/category_provider.dart';      // ← AGREGA ESTE
import 'providers/carousel_provider.dart';      // ← AGREGA ESTE
import 'services/supabase_service.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura aquí tus credenciales de Supabase
  await SupabaseService.initialize(
    supabaseUrl: 'https://cvzscfcciaegdgnyrkgg.supabase.co',
    supabaseAnonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2enNjZmNjaWFlZ2Rnbnlya2dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3OTQwMjMsImV4cCI6MjA3NjM3MDAyM30.dmAE84YXEtc9667I3b31fehIn_m8-9DIyBGrpppDRMY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),   // ← AGREGA ESTE
        ChangeNotifierProvider(create: (_) => CarouselProvider()),   // ← AGREGA ESTE
      ],
      child: MaterialApp(
        title: 'Radio App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
        routes: {
          '/admin-login': (context) => const AdminLoginScreen(),
        },
      ),
    );
  }
}