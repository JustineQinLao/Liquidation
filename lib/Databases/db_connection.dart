import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:liquidapp/Databases/model.dart';


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
    return await openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE dataTransaction(id INTEGER PRIMARY KEY, event TEXT, fund REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertDataTransaction(Liquidation dataTransaction) async {
    final db = await database;
    await db.insert(
      'dataTransaction',
      dataTransaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Liquidation>> getDataTransaction() async {
    
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('dataTransaction');
      return [
        for (final{
          'id': id as int,
          'event': event as String,
          'fund': fund as double,
        } in maps) Liquidation(
          id: id,
          event: event,
          fund: fund,
        ),
      ];
    
  }

  Future<void> updateTransaction(Liquidation dataTransaction) async { 
    final db = await database;
    await db.update(
      'dataTransaction',
      dataTransaction.toMap(),

      where: 'id = ?',

      whereArgs: [dataTransaction.id],
    );
  }



  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete(
      'dataTransaction',
      where: 'id = ?',

      whereArgs: [id],
    );
  }
}