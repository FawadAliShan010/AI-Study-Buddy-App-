// lib/features/test/supabase_test_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';

class SupabaseTestScreen extends StatelessWidget {
  const SupabaseTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✅ Supabase Connected!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Client: ${SupabaseConfig.client.auth.currentUser != null ? "User logged in" : "No user"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Test query
                  final response = await SupabaseConfig.client
                      .from('your_table_name')
                      .select('*')
                      .limit(1);
                  print('✅ Query successful: $response');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Query successful!')),
                  );
                } catch (e) {
                  print('❌ Query failed: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Test Database Query'),
            ),
          ],
        ),
      ),
    );
  }
}