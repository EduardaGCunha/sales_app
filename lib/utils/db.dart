
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DB {
  static const dbName = 'banco4';
  static const dbVersion = 2;

  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    final dbExists = await sql.databaseExists(path.join(dbPath, dbName));
    if (dbExists) {
      return sql.openDatabase(path.join(dbPath, dbName));
    }
    return _createDatabase(path.join(dbPath, dbName));
  }

  static Future<sql.Database> _createDatabase(String path) async {
    return sql.openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE products(id TEXT PRIMARY KEY, description TEXT, name TEXT, aplications TEXT, characteristics TEXT, lastUpdated TEXT, needFirebase INT, image TEXT, isDeleted INT, category TEXT)'
        );
      },
    );
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DB.database();
    await db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static deleteDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    await sql.deleteDatabase(dbPath);

  }

  static deleteInfo(String table, String id) async {
    final db = await DB.database();
    await db.delete(table, where: "id = ?", whereArgs: [id]);
  }

  static updateInfo(String table, String id, Map<String, dynamic> result) async{
    final db = await DB.database();

    await db.update(table, result, where: 'id = ?', whereArgs: [id]);
  }

  static getInfoFromDb(String table) async{
    final db = await DB.database();

    List data = await db.query(table);

    return data;
  }

}