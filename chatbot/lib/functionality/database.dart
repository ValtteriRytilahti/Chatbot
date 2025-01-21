import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chatbot.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  String friendlyBotInstructions = '''
  You are a friendly and approachable chatbot. Your responses should be warm, cheerful, and engaging. Use casual language and emojis where appropriate to make the conversation enjoyable.
  ''';

  String professionalBotInstructions = '''
  You are a professional and formal chatbot. Your responses should be polite, concise, and informative. Use formal language and avoid slang or emojis to maintain a professional tone.
  ''';

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE conversations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT
    )
    ''');
    await db.execute('''
    CREATE TABLE messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      conversation_id INTEGER,
      type TEXT,
      text TEXT,
      FOREIGN KEY(conversation_id) REFERENCES conversations(id)
    )
    ''');

    await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT,
      value TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE custom_prompts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      content TEXT
    )
    ''');

    // Insert default prompts
    await db.insert('custom_prompts', {
      'name': 'Friendly Bot',
      'content': friendlyBotInstructions,
    });

    await db.insert('custom_prompts', {
      'name': 'Professional Bot',
      'content': professionalBotInstructions,
    });
  }

  Future<int> createConversation(String title) async {
    final db = await instance.database;
    return await db.insert('conversations', {'title': title});
  }

  Future<void> insertMessage(int conversationId, String type, String text) async {
    final db = await instance.database;
    await db.insert('messages', {
      'conversation_id': conversationId,
      'type': type,
      'text': text,
    });
  }

  Future<void> updateSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateConversationTitle(int conversationId, String newTitle) async {
    final db = await instance.database;
    await db.update(
      'conversations',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<void> deleteConversation(int conversationId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
      );
      await txn.delete(
        'conversations',
        where: 'id = ?',
        whereArgs: [conversationId],
      );
    });
  }

  Future<Map<String, String>> getSettings() async {
    final db = await instance.database;
    final result = await db.query('settings');
    return {for (var row in result) row['key'] as String: row['value'] as String};
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await instance.database;
    return await db.query('conversations');
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final db = await instance.database;
    return await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<void> insertPrompt(String name, String content) async {
    final db = await instance.database;
    await db.insert('custom_prompts', {
      'name': name,
      'content': content,
    });
  }

  Future<void> deletePrompt(int id) async {
    final db = await instance.database;
    await db.delete(
      'custom_prompts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPrompts() async {
    final db = await instance.database;
    return await db.query('custom_prompts');
  }
}
