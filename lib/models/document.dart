import '../utils/date_utils.dart';
enum DocumentType {
  id,
  visa,
  insurance,
  certificate,
  other,
}

enum DocumentStatus {
  valid,
  expiringSoon,
  expired,
}
enum DocumentFilter {
  all,
  expired,
  expiringSoon,
}


class Document {
  final String id;
  final String name;
  final DocumentType type;
  final DateTime issueDate;
  final DateTime expiryDate;
  final int reminderDays;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.issueDate,
    required this.expiryDate,
    required this.reminderDays,
  });


 DocumentStatus getStatus() {
   final today = normalizeDate(DateTime.now());
   final expiry = normalizeDate(expiryDate);

   final daysLeft = expiry.difference(today).inDays;

   if (daysLeft < 0) {
     return DocumentStatus.expired;
   }

   if (daysLeft == 0) {
     return DocumentStatus.expired;
   }

   if (daysLeft <= reminderDays) {
     return DocumentStatus.expiringSoon;
   }

    return DocumentStatus.valid;
 }

  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'type': type.name,
    'issueDate': issueDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'reminderDays': reminderDays,
  };
}

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      name: map['name'],
      type: DocumentType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      issueDate: DateTime.parse(map['issueDate']),
      expiryDate: DateTime.parse(map['expiryDate']),
      reminderDays: map['reminderDays'],
    );
  }
}
