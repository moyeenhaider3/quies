import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:quies/data/services/user_preferences_service.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // For testing: reset onboarding
              await GetIt.instance<UserPreferencesService>().clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data cleared. Restart app to see onboarding.')),
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Breathing into the feed...'),
      ),
    );
  }
}
