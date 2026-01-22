import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/document.dart';


class DocumentListScreen extends StatelessWidget {
  final DocumentFilter filter;

  const DocumentListScreen({
    super.key,
    this.filter = DocumentFilter.all,
  });


   List<Document> _getDocuments() {
    final box = Hive.box('documents');
    final docs = box.values
        .map((e) => Document.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    docs.sort((a, b) => _statusPriority(a).compareTo(_statusPriority(b)));
    return docs;
  }

  int _statusPriority(Document doc) {
    switch (doc.getStatus()) {
      case DocumentStatus.expired:
        return 0;
      case DocumentStatus.expiringSoon:
        return 1;
      case DocumentStatus.valid:
        return 2;
    }
  }
  
  int _daysLeft(DateTime expiryDate) {
     final today = DateTime.now();
     final normalizedToday = DateTime(today.year, today.month, today.day);
     final normalizedExpiry =
         DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

     return normalizedExpiry.difference(normalizedToday).inDays;
  }
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
       '${date.month.toString().padLeft(2, '0')}/'
       '${date.year}';
  }
  String _buildSubtitle(Document doc) {
    final status = doc.getStatus();
    final daysLeft = _daysLeft(doc.expiryDate);

    if (status == DocumentStatus.expired) {
      return 'Expired on ${_formatDate(doc.expiryDate)}';
    }

    if (status == DocumentStatus.expiringSoon) {
       return 'Expires in $daysLeft days • ${_formatDate(doc.expiryDate)}';
    }
     return 'Expires on: ${_formatDate(doc.expiryDate)}';
  }

 @override
 Widget build(BuildContext context) {
  final box = Hive.box('documents');

  return ValueListenableBuilder(
   valueListenable: box.listenable(),
   builder: (context, Box box, _) {
    final allDocuments = _getDocuments();

    final documents = filter == DocumentFilter.all
      ? allDocuments
      : allDocuments.where((doc) {
        if (filter == DocumentFilter.expired) {
          return doc.getStatus() == DocumentStatus.expired;
        }
        if (filter == DocumentFilter.expiringSoon) {
          return doc.getStatus() == DocumentStatus.expiringSoon;
        }
        return true;
     }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _confirmClearAll(context);
              }
            },
           itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_all',
              child: Text('Clear All Documents'),
            ),
           ],
          ),
        ],
      ),
      body: documents.isEmpty
        ? const Center(child: Text('No documents found'))
        : ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return _buildDocumentTile(context, doc);
            },
        ),
     );
    },
   );
  }
   

   void _confirmClearAll(BuildContext context) {
     final box = Hive.box('documents');

     showDialog(
       context: context,
       builder: (_) => AlertDialog(
         title: const Text('Clear all documents?'),
         content: const Text(
           'This will permanently delete all stored documents.',
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel'),
           ),
           TextButton(
             onPressed: () {
               box.clear();
               Navigator.pop(context);
              
             },
             child: const Text(
              'Clear All',
               style: TextStyle(color: Colors.red),
             ),
           ),
         ],
       ),
     );
   }
   void _showItemActions(BuildContext context, Document doc) {
     showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Document'),
                onTap: () {
                  Hive.box('documents').delete(doc.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                 onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
       },
     );
    }

    Widget _buildDocumentTile(BuildContext context, Document doc) {
    final status = doc.getStatus();

    return ListTile(
      onLongPress: () => _showItemActions(context, doc),
      title: Text(doc.name),
      subtitle: Text(
        _buildSubtitle(doc),
      ),
      trailing: Text(
        _statusLabel(status),
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.expired:
        return 'EXPIRED';
      case DocumentStatus.expiringSoon:
        return 'EXPIRING SOON';
      case DocumentStatus.valid:
        return 'VALID';
    }
  }
   Color _statusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.expired:
        return Colors.red;
      case DocumentStatus.expiringSoon:
        return Colors.orange;
      case DocumentStatus.valid:
        return Colors.green;
    }
  }
  
}
