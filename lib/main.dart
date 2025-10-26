import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_app/screens/EventsScreen.dart';
import 'package:radio_app/screens/MembersScreen.dart';
import 'package:radio_app/screens/MusicScreen.dart';
import 'providers/content_provider.dart';
import 'providers/category_provider.dart'; // ← AGREGA ESTE
import 'providers/carousel_provider.dart'; // ← AGREGA ESTE
import 'services/supabase_service.dart';
import 'screens/home_screen.dart';

import 'screens/admin/admin_login_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

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
        ChangeNotifierProvider(
            create: (_) => CategoryProvider()), // ← AGREGA ESTE
        ChangeNotifierProvider(
            create: (_) => CarouselProvider()), // ← AGREGA ESTE
      ],
      child: MaterialApp(
        title: 'Radio Chacaltaya',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Montserrat',
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        routes: {
          '/admin-login': (context) => const AdminLoginScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Pantalla de Inicio con el reproductor
    MembersScreen(), // Pantalla de Miembros
    MusicScreen(), // Pantalla de Música
    EventsScreen(), // Pantalla de Eventos
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 255, 196, 0),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.home_12_regular),
          activeIcon: Icon(FluentIcons.home_12_filled),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.people_12_regular),
          activeIcon: Icon(FluentIcons.people_12_filled),
          label: 'Miembros',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.music_note_2_24_regular),
          activeIcon: Icon(FluentIcons.music_note_2_24_filled),
          label: 'Música',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.calendar_16_regular),
          activeIcon: Icon(FluentIcons.calendar_12_filled),
          label: 'Eventos',
        ),
      ],
    );
  }
}
