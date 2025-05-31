import 'package:note_app_salsabila/model/model_note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            isPinned INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN createdAt TEXT');
        }
      },
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final result = await db.query(
      'notes',
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;

    final noteToInsert = note.createdAt == null
        ? Note(
      id: note.id,
      title: note.title,
      content: note.content,
      isPinned: note.isPinned,
      createdAt: DateTime.now(),
    )
        : note;

    return await db.insert('notes', noteToInsert.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }
}