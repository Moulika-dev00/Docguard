
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/document.dart';
import 'document_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<DocumentStatus, int> _getCounts() {
    final box = Hive.box('documents');
    final documents = box.values
        .map((e) => Document.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    int expired = 0;
    int expiringSoon = 0;
    int valid = 0;

    for (final doc in documents) {
      switch (doc.getStatus()) {
        case DocumentStatus.expired:
          expired++;
          break;
        case DocumentStatus.expiringSoon:
          expiringSoon++;
          break;
        case DocumentStatus.valid:
          valid++;
          break;
      }
    }

    return {
      DocumentStatus.expired: expired,
      DocumentStatus.expiringSoon: expiringSoon,
      DocumentStatus.valid: valid,
    };
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('documents');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        final counts = _getCounts();
        final total = counts.values.fold(0, (a, b) => a + b);

        return Scaffold(
          appBar: AppBar(
            title: const Text('DocGuard'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DocumentListScreen(
                          filter: DocumentFilter.expired,
                       ),
                      ),
                   );
                 },
                 child: _buildCard(
                   title: 'Expired Documents',
                   value: counts[DocumentStatus.expired].toString(),
                   color: Colors.red,
                 ),
                ),

                const SizedBox(height: 12),
                InkWell(
                 onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => const DocumentListScreen(
                         filter: DocumentFilter.expiringSoon,
                        ),
                      ),
                   );
                 },
                  child: _buildCard(
                   title: 'Expiring Soon',
                   value: counts[DocumentStatus.expiringSoon].toString(),
                   color: Colors.orange,
                 ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => const DocumentListScreen(
                         filter: DocumentFilter.all,
                       ),
                     ),
                   );
                 },
                  child: _buildCard(
                  title: 'Total Documents',
                  value: total.toString(),
                  color: Colors.blue,
                ),
               ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
