import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/church_provider.dart';

class ChurchesListScreen extends StatelessWidget {
  const ChurchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Churches")),
      body: Consumer<ChurchProvider>(
        builder: (context, churchProvider, child) {
          if (churchProvider.churches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            itemCount: churchProvider.churches.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final church = churchProvider.churches[index];
              return ListTile(
                leading: const Icon(Icons.church),
                title: Text(church.name),
                subtitle: Text(church.address),
              );
            },
          );
        },
      ),
    );
  }
}
