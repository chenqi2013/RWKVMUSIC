const String tableNotes = 'notes';

class NoteFields {
  static final List<String> values = [
    /// Add all fields
    id, isUserCreate, orderNumber, title, content, createdTime
  ];

  static const String id = '_id';
  static const String isUserCreate = 'isUserCreate';
  static const String orderNumber = 'orderNumber';
  static const String title = 'title';
  static const String content = 'content';
  static const String createdTime = 'createdTime';
}

class Note {
  final int? id;
  final bool isUserCreate;
  final int orderNumber;
  final String title;
  final String content;
  final DateTime createdTime;

  const Note({
    this.id,
    required this.isUserCreate,
    required this.orderNumber,
    required this.title,
    required this.content,
    required this.createdTime,
  });

  Note copy({
    int? id,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? createdTime,
  }) =>
      Note(
        id: id ?? this.id,
        isUserCreate: isImportant ?? isUserCreate,
        orderNumber: number ?? orderNumber,
        title: title ?? this.title,
        content: description ?? content,
        createdTime: createdTime ?? this.createdTime,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        isUserCreate: json[NoteFields.isUserCreate] == 1,
        orderNumber: json[NoteFields.orderNumber] as int,
        title: json[NoteFields.title] as String,
        content: json[NoteFields.content] as String,
        createdTime: DateTime.parse(json[NoteFields.createdTime] as String),
      );

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.title: title,
        NoteFields.isUserCreate: isUserCreate ? 1 : 0,
        NoteFields.orderNumber: orderNumber,
        NoteFields.content: content,
        NoteFields.createdTime: createdTime.toIso8601String(),
      };
}
