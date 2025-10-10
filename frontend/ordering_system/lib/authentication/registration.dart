import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// API
import '../service/api_services.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final numPhone = TextEditingController();

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (password.text != confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password do not match',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ),
        );
        return;
      }
      try {
        final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
        final payload = {
          "name": name.text,
          "username": username.text,
          "email": email.text,
          "password": password.text,
          "role": "customer",
          "phoneNum": numPhone.text,
        };
        final resp = await api.registerUser(payload);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),
        );
      } catch (e) {
        // IMPLEMENTATION LATER
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    numPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create an Account',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 37, 31, 33),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              double formWidth;
              if (screenWidth < 600) {
                formWidth = screenWidth * 0.9;
              } else if (screenWidth < 1024) {
                formWidth = screenWidth * 0.7;
              } else {
                formWidth = screenWidth * 0.5;
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: formWidth),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: name,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: GoogleFonts.montserrat(),
                              border: const OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your name'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: GoogleFonts.montserrat(),
                              border: const OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your username'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.montserrat(),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your email'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: password,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.montserrat(),
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your password'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: confirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: GoogleFonts.montserrat(),
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter confirmation password'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: numPhone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number +60',
                              labelStyle: GoogleFonts.montserrat(),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your phone number'
                                        : null,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _createAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
