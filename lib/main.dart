import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_learning/screens/auth_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 🔁 Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 BG Message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧠 Firebase Init
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCqObMCgd_WwPTErSTLe-LfQczEAAOjTvs",
        authDomain: "learnfirebase-07v.firebaseapp.com",
        projectId: "learnfirebase-07v",
        storageBucket: "learnfirebase-07v.firebasestorage.app",
        messagingSenderId: "237702135318",
        appId: "1:237702135318:web:505bf952e7a04ab5a1bf37",
        measurementId: "G-YB2E6Y2S92",
      ),
    );
  } else {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔐 Permission request (Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("✅ Notification permission granted");

      // 🔔 Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("📥 Foreground Message: ${message.notification?.title}");
        debugPrint("📄 Message body: ${message.notification?.body}");
      });

      // 🔑 FCM Token
      final token = await messaging.getToken();
      debugPrint("🔑 FCM Token: $token");

      // TODO: Save this token to Firestore with user UID if needed
    } else {
      debugPrint("❌ Notification permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Note App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
