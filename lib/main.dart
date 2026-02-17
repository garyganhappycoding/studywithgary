import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studywithgary/services/background_timer_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initializeNotifications();
  await BackgroundTimerService.initializeBackgroundService();
  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInitializationSettings =
  AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: androidInitializationSettings,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

  // ✅ CREATE NOTIFICATION CHANNEL FOR ANDROID 8.0+
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
    const AndroidNotificationChannel(
      'timer_channel',
      'Study Timer Service',
      description: 'Notification for active study timer',
      importance: Importance.low,
      enableVibration: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'study with gary',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}