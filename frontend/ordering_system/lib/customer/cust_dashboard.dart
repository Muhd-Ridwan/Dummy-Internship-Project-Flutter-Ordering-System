import 'package:flutter/material.dart';

class CustDashboard extends StatefulWidget {
  const CustDashboard({super.key});

  @override
  State<CustDashboard> createState() => _CustDashboardState();
}

class _CustDashboardState extends State<CustDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Dashboard')),
      body: const Center(child: Text('Welcome to the Customer Dashboard!')),
    );
  }
}
