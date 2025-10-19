import 'package:flutter/material.dart';
import '../service/api_services.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiServices api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
  String output = '';

  Future<void> doGet() async {
    setState(() => output = 'loading...');
    try {
      final users = await api.fetchUsers();
      setState(() => output = users.toString());
    } catch (e) {
      setState(() => output = 'GET error: $e');
    }
  }

  Future<void> doPost() async {
    setState(() => output = 'posting...');
    try {
      final resp = await api.postData({'name': 'flutter', 'value': 1});
      setState(() => output = resp.toString());
    } catch (e) {
      setState(() => output = 'POST error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: doGet, child: const Text('GET /api/')),
            ElevatedButton(onPressed: doPost, child: const Text('POST /api/')),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(output))),
          ],
        ),
      ),
    );
  }
}
