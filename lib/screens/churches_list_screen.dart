import 'package:flutter/material.dart';

class ChurchesListScreen extends StatelessWidget {
  const ChurchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Churches")),
      body: const Center(
        child: Text(
          "Churches list will appear here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
