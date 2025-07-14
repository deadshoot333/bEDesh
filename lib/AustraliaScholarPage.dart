import 'package:flutter/material.dart';

class AustraliaScholarPage extends StatelessWidget {
  const AustraliaScholarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Australia Scholarship"),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          "Details about Australia Scholarships coming soon!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
