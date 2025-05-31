class Note {
  final int? id;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime? createdAt;  // tanggal catatan dibuat

  Note({
    this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.createdAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isPinned: map['isPinned'] == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isPinned': isPinned ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(), // simpan sebagai string ISO8601
    };
  }
}