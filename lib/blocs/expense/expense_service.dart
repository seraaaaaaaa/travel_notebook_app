import 'package:travel_notebook/models/destination/destination_field.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_field.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/services/database_helper.dart'; // Import the database instance

class ExpenseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Expense>> readAllExpenses(int destinationId, int? limit) async {
    final db = await _databaseHelper.database;
    const orderBy = '${ExpenseField.createdTime} DESC';

    final result = await db.query(
      ExpenseField.tableName,
      where: '${ExpenseField.destinationId} = ?',
      whereArgs: [destinationId],
      orderBy: orderBy,
      limit: limit,
    );

    return result.map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> readExpense(int id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      ExpenseField.tableName,
      columns: ExpenseField.values,
      where: '${ExpenseField.expenseId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<String> createExpense(Expense expense, Destination destination) async {
    final db = await _databaseHelper.database;
    final id = await db.insert(ExpenseField.tableName, expense.toJson());

    await db.update(
      DestinationField.tableName,
      destination.toJson(),
      where: '${DestinationField.destinationId} = ?',
      whereArgs: [destination.destinationId],
    );

    if (id > 0) {
      return 'Expense recorded successfully';
    } else {
      return 'Failed to record expense';
    }
  }

  Future<int> updateExpense(Expense expense, Destination destination) async {
    final db = await _databaseHelper.database;

    final result = db.update(
      ExpenseField.tableName,
      expense.toJson(),
      where: '${ExpenseField.expenseId} = ?',
      whereArgs: [expense.expenseId],
    );

    await db.update(
      DestinationField.tableName,
      destination.toJson(),
      where: '${DestinationField.destinationId} = ?',
      whereArgs: [destination.destinationId],
    );

    return result;
  }

  Future<String> deleteExpense(int expenseId, Destination destination) async {
    final db = await _databaseHelper.database;

    int result = await db.delete(
      ExpenseField.tableName,
      where: '${ExpenseField.expenseId} = ?',
      whereArgs: [expenseId],
    );

    await db.update(
      DestinationField.tableName,
      destination.toJson(),
      where: '${DestinationField.destinationId} = ?',
      whereArgs: [destination.destinationId],
    );

    if (result > 0) {
      return 'Expense deleted successfully';
    } else {
      return 'Failed to delete expense';
    }
  }
}
