import 'package:travel_notebook/models/destination/destination_field.dart';
import 'package:travel_notebook/models/expense/expense_field.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_notebook/models/todo/todo_field.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT';
  static const String intType = 'INTEGER';
  static const String doubleType = 'REAL';

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'travel.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE ${DestinationField.tableName} ADD COLUMN ${DestinationField.decimal} $intType DEFAULT 0
    ''');
    }

    // if (oldVersion < 3) {
    //   await db.execute('''
    //   ALTER TABLE ${ExpenseField.tableName} ADD COLUMN ${ExpenseField.sequence} $intType DEFAULT 0
    // ''');
    // }

    if (oldVersion < 4) {
      await db.execute('''
      ALTER TABLE ${ExpenseField.tableName} ADD COLUMN ${ExpenseField.excludeBudget} $intType DEFAULT 0
    ''');
    }
  }

  void _createDatabase(Database db, _) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DestinationField.tableName} (
          ${DestinationField.destinationId} $idType,
          ${DestinationField.name} $textType,
          ${DestinationField.imgPath} $textType,
          ${DestinationField.startDate} $textType,    
          ${DestinationField.endDate} $textType,    
          ${DestinationField.budget} $doubleType,
          ${DestinationField.currency} $textType,  
          ${DestinationField.decimal} $intType,  
          ${DestinationField.rate} $doubleType,
          ${DestinationField.isPin} $intType,
          ${DestinationField.totalExpense} $doubleType,
          ${DestinationField.totalTransport} $doubleType,
          ${DestinationField.totalMeal} $doubleType,
          ${DestinationField.totalMisc} $doubleType
        )
      ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS ${ExpenseField.tableName} (
          ${ExpenseField.expenseId} $idType,
          ${ExpenseField.destinationId} $intType,
          ${ExpenseField.amount} $doubleType,
          ${ExpenseField.converted} $doubleType,
          ${ExpenseField.paymentMethod} $textType,
          ${ExpenseField.typeNo} $intType,
          ${ExpenseField.typeName} $textType,
          ${ExpenseField.remark} $textType,    
          ${ExpenseField.receiptImg} $textType,
          ${ExpenseField.createdTime} $textType,
          ${ExpenseField.excludeBudget} $intType
        )
      ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS ${TodoField.tableName} (
          ${TodoField.id} $idType,
          ${TodoField.destinationId} $intType,
          ${TodoField.categoryId} $intType,
          ${TodoField.content} $textType,
          ${TodoField.status} $intType,
          ${TodoField.sequence} $intType
        )
      ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
