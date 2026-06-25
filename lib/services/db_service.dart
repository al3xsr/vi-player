import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vi/models/track_model.dart';

class DatabaseService {
  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  // INIT DB
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'vi_player.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tracks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          path TEXT NOT NULL UNIQUE,
          title TEXT NOT NULL,
          artist TEXT,
          album TEXT,
          duration INTEGER,
          is_favorite INTEGER DEFAULT 0
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE tracks ADD COLUMN is_favorite INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  // ── CRUD ──────────────────────────────────

  Future<void> insertTrack(TrackModel track) async {
    final db = await database;
    await db.insert(
      'tracks',
      track.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, // if exists, ignore
    );
  }


  Future<void> insertTracks(List<TrackModel> tracks) async {
    final db = await database;
    final batch = db.batch(); 
    for (final track in tracks) {
      batch.insert(
        'tracks',
        track.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  
  Future<List<TrackModel>> getAllTracks() async {
    final db = await database;
    final maps = await db.query('tracks', orderBy: 'title ASC');
    return maps.map((m) => TrackModel.fromMap(m)).toList();
  }

  
  Future<void> deleteTrack(int id) async {
    final db = await database;
    await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }

  
  Future<void> clearTracks() async {
    final db = await database;
    await db.delete('tracks');
  }

  
  Future<void> toggleFavorite(TrackModel track) async {
    final db = await database;
    await db.update(
      'tracks',
      {'is_favorite': track.isFavorite ? 0 : 1},
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }


  Future<List<TrackModel>> getFavorites() async {
    final db = await database;
    final maps = await db.query(
      'tracks',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'title ASC',
    );
    return maps.map((m) => TrackModel.fromMap(m)).toList();
  }
}
