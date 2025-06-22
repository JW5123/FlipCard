import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flip_card.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime INTEGER NOT NULL,
        secondsSpent INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertGameRecord(GameRecord record) async {
    final db = await database;
    return await db.insert('game_records', record.toMap());
  }

  Future<List<GameRecord>> getAllGameRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_records',
      orderBy: 'dateTime DESC',
    );

    return List.generate(maps.length, (i) {
      return GameRecord.fromMap(maps[i]);
    });
  }

  Future<GameRecord?> getBestRecord() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_records',
      orderBy: 'secondsSpent ASC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return GameRecord.fromMap(maps.first);
  }

  Future<int> getTotalGames() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM game_records');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearAllRecords() async {
    final db = await database;
    await db.delete('game_records');
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete('game_records', where: 'id = ?', whereArgs: [id]);
  }
}