import 'package:path/path.dart';
import 'package:pokemon_special_app/database/cache_table.dart';
import 'package:sqflite/sqflite.dart';

class PokemonMangaDatabase {
  static const DB_NAME = 'pokemon_manga.db';
  static const DB_VERSION = 1;
  static Database _database;

  Database get database => _database;

  PokemonMangaDatabase._internal();
  static final PokemonMangaDatabase instance = PokemonMangaDatabase._internal();

  static const initScript = [
    CacheMangaTable.CREATE_TABLE
  ];

  static const migrationScript = [
    CacheMangaTable.CREATE_TABLE
  ];

  init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) {
        initScript.forEach((script) async => await db.execute(script));
      },
      onUpgrade: (db, oldVersion, newVersion) {
        migrationScript.forEach((script) async => await db.execute(script));
      },
      version: DB_VERSION
    );
  }
}