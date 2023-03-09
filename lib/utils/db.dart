
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DB {
  static const dbName = 'banco17';
  static const dbVersion = 1;

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
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE sync (id TEXT PRIMARY KEY, tableName TEXT, crud TEXT)');
        await db.execute('CREATE TABLE products (id TEXT PRIMARY KEY, description TEXT, name TEXT, aplications TEXT, characteristics TEXT, lastUpdated TEXT, needFirebase INT, image TEXT, isDeleted INT, category TEXT)');
        await db.execute('CREATE TABLE obras (id TEXT PRIMARY KEY, enterprise TEXT, address TEXT, owner TEXT, responsible TEXT, lastUpdated TEXT, image TEXT, products TEXT, isDeleted INT, data TEXT, firebaseId TEXT)');
        await db.execute('CREATE TABLE projects (id TEXT PRIMARY KEY, engineer TEXT, begDate TEXT, endDate TEXT, civil TEXT, lastUpdated TEXT, eletrical TEXT, isDeleted INT, financial TEXT, firebaseId TEXT, pdfFile TEXT, matchmakingId TEXT)');
        await db.execute('CREATE TABLE diaries (id TEXT PRIMARY KEY, description TEXT, date TEXT, initiatedServ TEXT, finishedServ TEXT, lastUpdated TEXT, currentPhase TEXT, isDeleted INT, images TEXT, firebaseId TEXT, matchmakingId TEXT)');
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

 static deleteInfo(String table, String id, {String? crud}) async {
    final db = await DB.database();
    if (crud == null) {
        await db.delete(table, where: "id = ?", whereArgs: [id]);
    } else {
        await db.delete(table, where: "id = ? AND crud = ?", whereArgs: [id, crud]);
    }
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

  static Future<void> batch(String table, dataList) async {
    final db = await database();
    final batch = db.batch();

    for (var data in dataList) {
      batch.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

}