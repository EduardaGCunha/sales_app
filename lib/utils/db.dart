
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';


class DB {
  static Future<sql.Database> database() async {
    int version = 1;
    final dbPath = await sql.getDatabasesPath();

    if(await sql.databaseExists(dbPath)){
      var database = await sql.openDatabase(dbPath);

      if(await database.getVersion() < version){
        await sql.deleteDatabase(dbPath);
        
        return sql.openDatabase(
          path.join(dbPath, 'quality.db'),
          onCreate:  (db, version) {
            return db.execute(
              'CREATE TABLE obras(id TEXT PRIMARY KEY, address TEXT, name TEXT, owner TEXT,engineer TEXT)'
            );
          },
          version: version,
        );
      }

      return database;
    }

    return sql.openDatabase(
      path.join(dbPath, 'quality.db'),
      onCreate:  (db, version) {
        return db.execute(
          'CREATE TABLE obras(id TEXT PRIMARY KEY, address TEXT, name TEXT, owner TEXT,engineer TEXT)'
        );
      },
      version: version,
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