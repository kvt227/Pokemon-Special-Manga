import 'package:pokemon_special_app/database/pokemon_manga_db.dart';
import 'package:pokemon_special_app/model/cache_manga.dart';
import 'package:sqflite/sqflite.dart';

class CacheMangaTable {
  static const TABLE_NAME = 'CacheManga';
  static const CREATE_TABLE = '''
    CREATE TABLE $TABLE_NAME (
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      MangaName TEXT,
      Chapter INT
    )
  ''';

  static const DROP_TABLE = '''
    DROP TABLE IF EXISTS $TABLE_NAME
  ''';

  Future<int> insert(CacheManga building) {
    final Database db = PokemonMangaDatabase.instance.database;
    return db.insert(
        TABLE_NAME,
        building.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<int> update(CacheManga building) {
    final Database db = PokemonMangaDatabase.instance.database;
    return db.update(
        TABLE_NAME,
        building.toMap(),
        where: 'id = ?',
        whereArgs: [building.id],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> delete(CacheManga building) async {
    final Database db = PokemonMangaDatabase.instance.database;
    await db.delete(
        TABLE_NAME,
        where: 'id = ?',
        whereArgs: [building.id]
    );
  }

  Future<CacheManga> selectById(int id) async {
    final Database db = PokemonMangaDatabase.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1
    );

    if (maps.length == 0) {
      return null;
    }

    return CacheManga.fromData(
        maps[0]['ID'],
        maps[0]['MangaName'],
        maps[0]['Chapter']
    );
  }

  Future<List<CacheManga>> selectAll() async {
    final Database db = PokemonMangaDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);

    return List.generate(maps.length, (index) {
      return CacheManga.fromData(
          maps[index]['id'],
          maps[index]['chapter'],
          maps[index]['mangaName']
      );
    });
  }
}