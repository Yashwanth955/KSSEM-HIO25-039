// lib/sponsor_screen.dart
import 'package:flutter/material.dart';
import 'isar_service.dart';
import 'sponsor_model.dart';

class SponsorScreen extends StatelessWidget {
  const SponsorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isarService = IsarService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsors & Mentors'),
      ),
      body: FutureBuilder<List<Sponsor>>(
        future: isarService.getAllSponsors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sponsors are available right now.'));
          }
          final sponsors = snapshot.data!;
          return ListView.builder(
            itemCount: sponsors.length,
            itemBuilder: (context, index) {
              final sponsor = sponsors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    sponsor.type == 'Sponsor' ? Icons.business : Icons.person,
                    color: Colors.green,
                  ),
                  title: Text(sponsor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Focus: ${sponsor.focusSport}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () { /* TODO: Navigate to a sponsor detail page */ },
                ),
              );
            },
          );
        },
      ),
    );
  }
}