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
  final int? isUserCreate;
  final int? orderNumber;
  final String? title;
  final String? content;
  final String? createdTime;

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
    int? isUserCreate,
    int? orderNumber,
    String? title,
    String? content,
    String? createdTime,
  }) =>
      Note(
        id: id,
        isUserCreate: isUserCreate,
        orderNumber: orderNumber,
        title: title,
        content: content,
        createdTime: createdTime,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        isUserCreate: json[NoteFields.isUserCreate] as int,
        orderNumber: json[NoteFields.orderNumber] as int,
        title: json[NoteFields.title] as String,
        content: json[NoteFields.content] as String,
        createdTime: json[NoteFields.createdTime] as String,
      );

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.title: title,
        NoteFields.isUserCreate: isUserCreate,
        NoteFields.orderNumber: orderNumber,
        NoteFields.content: content,
        NoteFields.createdTime: createdTime,
      };
}
