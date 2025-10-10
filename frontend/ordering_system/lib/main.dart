import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ordering_system/authentication/forgotPassword.dart';
import 'package:ordering_system/authentication/registration.dart';
import 'package:ordering_system/service/api_test.dart';
import 'package:provider/provider.dart';

// PROVIDERS
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// SCREENS
import 'authentication/login.dart';

Future<void> main() async {
  await startApp();
}

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ENTER DJANGO MAYBE

  // LOCK IN POTRAIT MODE
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Ordering System',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: AuthGate(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const Register(),
            '/forgot': (context) => const ForgotPassword(),
            '/apitest': (context) => const ApiTestScreen(),
          },
        );
      },
    );
  }
}

// FOR AUTHENTICATION USING DJANGO LATER
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // final auth = context.watch<AppAuthProvider>();
    // switch (auth.status) {
    //   case AuthStatus.checking:
    //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
    //   case AuthStatus.authenticated:
    //     return const HomeScreen();
    //   case AuthStatus.unauthenticated:
    //     return const LoginScreen();

    return const LoginScreen();
  }
}

//}
