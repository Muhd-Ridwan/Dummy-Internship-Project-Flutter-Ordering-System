import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ordering_system/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../service/api_services.dart';
import 'package:text_3d/text_3d.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // LOGIN LOGIC USING ENTER BUTTON
  Future<void> _attemptLogin() async {
    final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
    final uname = _username.text.trim();
    final pwd = _passwordController.text.trim();

    if (uname.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username and password')),
      );
      return;
    }

    try {
      // Try custom /api/login/ first if return user+ token
      String? token;
      try {
        final resp = await api.login(uname, pwd);

        // TRYING EXTRACT TOKEN
        token =
            (resp['access'] as String?) ??
            (resp['token'] as String?) ??
            (resp['auth_token'] as String?);
      } catch (_) {
        // ignore, keep token null if not available
        // FALLBACK TO OUTSIDE TRY
      }

      token ??= (await api.obtainToken(uname, pwd))['access'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in response');
      }

      await api.saveAccessToken(token);

      // FETCHING CURRENT USER
      final me = await api.getUser(token);
      final int userId = (me['id'] as num).toInt();
      final String email = (me['email'] as String?) ?? uname;
      final String role = (me['role'] as String? ?? '').toLowerCase();

      context.read<AppAuthProvider>().login(
        email: email,
        userId: userId,
        token: token,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login Successful')));

      if (role == 'customer') {
        Navigator.pushNamedAndRemoveUntil(context, '/product', (_) => false);
      } else {
        //
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
    }
  }

  // LOGIN LOGIC USING ENTER BUTTON END

  @override
  Widget build(BuildContext context) {
    // USING POP SCOPE TO DISABLE GESTURE OR BACK BUTTON. MUEHEHEHEHE
    return PopScope(
      canPop: false, // <-- disables system back & gesture pop on this page
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tekunorogi Shoppuru',
                softWrap: true,
                style: GoogleFonts.moonDance(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Login',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _username,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _attemptLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final usernameText = _username.text.trim();
                    final passwordText = _passwordController.text.trim();

                    if (usernameText.isEmpty || passwordText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter username and password'),
                        ),
                      );
                      return;
                    }

                    try {
                      final api = ApiServices(
                        baseUrl: ApiServices.defaultBaseUrl(),
                      );

                      final resp = await api.login(usernameText, passwordText);
                      final String? tokenStr =
                          resp['access'] as String? ?? resp['token'] as String?;

                      if (tokenStr == null || tokenStr.isEmpty) {
                        throw Exception('Token not found in response');
                      }

                      // FOR PERSIST TOKEN
                      await api.saveAccessToken(tokenStr);

                      // FETCHING CURRENT USER
                      final me = await api.getUser(tokenStr);
                      // EXPECTED IS IN JSON {id: 1, email: adjhajdhaj@gmail.com, role: customer}
                      final int userId = (me['id'] as num).toInt();
                      final String email =
                          (me['email'] as String?) ?? usernameText;
                      final String role =
                          (me['role'] as String? ?? '').toLowerCase();

                      // SAVE TO PROVIDER
                      context.read<AppAuthProvider>().login(
                        email: email,
                        userId: userId,
                        token: tokenStr,
                      );

                      print('This is the token for logging in : $tokenStr');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login Successful')),
                      );

                      // PAGE ROUTE FOR ROLE PURPOSES
                      if (role == 'customer') {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/product',
                          (_) => false,
                        );
                      } else {
                        //
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login Failed: $e')),
                      );
                    }
                  },
                  child: Text(
                    'Login',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // normal push so user can come back to Login
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Create an Account',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot');
                  },
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
