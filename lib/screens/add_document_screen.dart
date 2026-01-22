import 'package:flutter/material.dart';
import '../models/document.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';


class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  DocumentType _selectedType = DocumentType.id;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  int _reminderDays = 30;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
             children: [
              _buildNameField(),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Issue Date',
                selectedDate: _issueDate,
                onPick: (date) => setState(() => _issueDate = date),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Expiry Date',
                selectedDate: _expiryDate,
                onPick: (date) => setState(() => _expiryDate = date),
              ),
              const SizedBox(height: 16),
              _buildReminderDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Document'),
              ),
             ],
           ),
        ),
      ),
    );
  }

   Widget _buildNameField() {
     return TextFormField(
       controller: _nameController,
       decoration: const InputDecoration(
         labelText: 'Document Name',
         border: OutlineInputBorder(),
       ),
       validator: (value) {
         if (value == null || value.trim().isEmpty) {
           return 'Please enter document name';
         }
         return null;
       },
     );
   }
    Widget _buildTypeDropdown() {
      return DropdownButtonFormField<DocumentType>(
        value: _selectedType,
        decoration: const InputDecoration(
          labelText: 'Document Type',
          border: OutlineInputBorder(),
       ),
       items: DocumentType.values.map((type) {
         return DropdownMenuItem(
           value: type,
           child: Text(type.name.toUpperCase()),
         );
       }).toList(),
        onChanged: (value) {
           if (value != null) {
             setState(() => _selectedType = value);
           }
         },
      );
    }
    Widget _buildDatePicker({
      required String label,
      required DateTime? selectedDate,
      required Function(DateTime) onPick,
    }) {
        return InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
           );

            if (pickedDate != null) {
              onPick(pickedDate);
            }
         },
         child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            child: Text(
              selectedDate == null
                 ? 'Select date'
                 : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
               ),
           ), 
        );
    }
     Widget _buildReminderDropdown() {
       return DropdownButtonFormField<int>(
         value: _reminderDays,
         decoration: const InputDecoration(
           labelText: 'Reminder Days',
           border: OutlineInputBorder(),
         ),
         items: const [
            DropdownMenuItem(value: 30, child: Text('30 days')),
            DropdownMenuItem(value: 15, child: Text('15 days')),
            DropdownMenuItem(value: 7, child: Text('7 days')),
         ],
         onChanged: (value) {
           if (value != null) {
             setState(() => _reminderDays = value);
           }
         },
       );
     }
      void _submitForm() {
        if (!_formKey.currentState!.validate()) {
          return;
       }

       if (_issueDate == null || _expiryDate == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please select both dates')),
         );
          return;
       }
 
       if (_expiryDate!.isBefore(_issueDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
             content: Text('Expiry date must be after issue date'),
           ),
         );
         return;
       }

       final doc = Document(
         id: const Uuid().v4(),
         name: _nameController.text.trim(),
         type: _selectedType,
         issueDate: _issueDate!,
         expiryDate: _expiryDate!,
         reminderDays: _reminderDays,
       );

        final box = Hive.box('documents');
        box.put(doc.id, doc.toMap());

       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Document saved successfully'),
         duration: Duration(seconds: 1),
         ),
       );

 
      }

}
