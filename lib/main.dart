import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_api.dart';
import 'homescreen.dart';
import 'notificationscreen.dart';
import 'Autentication/signIn.dart';
import 'splash_screen.dart';
import 'localization/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  //print('Stripe Publishable Key: ${dotenv.env['STRIPE_PUBLISHABLE_KEY']}');
  Stripe.publishableKey = 'pk_test_51QjzvP2MzP0OYbhEKoM6kjBK4gqmASalWYjpdknqhpMqtqW1FG8kKGEeYGqanvMMgfiAA27L5l4HbvLUS5ZEabZn00wPxeYk1l';
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'your_default_key';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  await Stripe.instance.applySettings();


  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseApi().initNotifications();

  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    print('Changing locale to: ${locale.languageCode}');
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('hi'), // Hindi
        Locale('mr'), // Marathi
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom JSON localization
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(
        onLocaleChange: _setLocale, // 👈 Pass locale change to SplashScreen
      ),
      routes: {
    '/home': (context) => HomeScreen(
    onLocaleChange: (locale) {
    setState(() {
    _locale = locale;
    });
    },
    //  locale: _locale, // ✅ Pass _locale to HomeScreen
    // ✅ Pass to HomeScreen
        ),
        '/signIn': (context) => SignInScreen(
          onLocaleChange: _setLocale,
        ),
        '/notification_screen': (context) => const Notificationscreen(),
      },
    );
  }
}
