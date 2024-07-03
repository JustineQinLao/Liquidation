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
        // return db.execute(
        //   'CREATE TABLE dataTransaction(id INTEGER PRIMARY KEY, event TEXT, fund REAL)',
        // );
        db.execute(
          'CREATE TABLE dataTransaction(id INTEGER PRIMARY KEY, event TEXT, fund REAL)',
        );
        db.execute(
          'CREATE TABLE TransactionDetails(id INTEGER PRIMARY KEY, date TEXT, payee TEXT, or_si TEXT, particulars TEXT, amount REAL, transactionId INTEGER, image TEXT, FOREIGN KEY(transactionId) REFERENCES dataTransaction(id))',
        );
        // db.execute(
        
        // );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
        db.execute('ALTER TABLE TransactionDetails ADD COLUMN image TEXT');
      }
      },
      version: 2,
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

   Future<void> insertTransactionDetails(TransactionDetails details) async {
    final db = await database;
    await db.insert(
      'TransactionDetails',
      details.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Liquidation>> getDataTransaction() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('dataTransaction');
    return [
      for (final {
            'id': id as int,
            'event': event as String,
            'fund': fund as double,
          } in maps)
        Liquidation(
          id: id,
          event: event,
          fund: fund,
        ),
    ];
  }


  //
  Future<List<TransactionDetails>> getTransactionDetails(int transactionId) async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      'TransactionDetails',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    return [
      for (final {
        'id': id as int,
        'date': date as String,
        'payee': payee as String,
        'or_si': or_si as String,
        'particulars': particulars as String,
        'amount': amount as double,
        'image': image as String,
      } in maps) TransactionDetails(
        id: id,
        date: date,
        payee: payee,
        or_si: or_si,
        particulars: particulars,
        amount: amount,
        image: image,
        transactionId: transactionId,
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


  //
  Future<void> updateTransactionDetails(TransactionDetails details) async {
    final db = await database;
    await db.update(
      'TransactionDetails',
      details.toMap(),
      where: 'id = ?',
      whereArgs: [details.id],
    );
  }

  // Future<void> deleteTransaction(int id) async {
  //   final db = await database;
  //   await db.delete(
  //     'dataTransaction',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }
  Future<void> deleteTransaction(int id) async {
    final db = await database;
    // First, delete the associated transaction details
    await db.delete(
      'TransactionDetails',
      where: 'transactionId = ?',
      whereArgs: [id],
    );
    // Then, delete the transaction itself
    await db.delete(
      'dataTransaction',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //
  Future<void> deleteTransactionDetails(int id) async {
    final db = await database;
    await db.delete(
      'TransactionDetails',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
