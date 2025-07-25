import 'package:travel_notebook/models/destination/destination_field.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_field.dart';
import 'package:travel_notebook/models/expense/expense_model.dart';
import 'package:travel_notebook/services/database_helper.dart'; // Import the database instance

class ExpenseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Expense>> readAllExpenses(int destinationId, int? limit,
      int typeNo, String paymentMethod, int? inclBudget) async {
    final db = await _databaseHelper.database;

    var orderBy = '${ExpenseField.createdTime} DESC';

    if (limit == 4) {
      orderBy = '${ExpenseField.createdTime} DESC';
    }

    var where = '${ExpenseField.destinationId} = ?';
    List<dynamic> whereArgs = [destinationId];

    if (typeNo > 0) {
      where += " AND ${ExpenseField.typeNo} = ?";
      whereArgs.add(typeNo);
    }

    if (paymentMethod.isNotEmpty) {
      where += " AND ${ExpenseField.paymentMethod} = ?";
      whereArgs.add(paymentMethod);
    }

    if (inclBudget != null) {
      where += " AND ${ExpenseField.excludeBudget} = ?";
      whereArgs.add(inclBudget);
    }

    final result = await db.query(
      ExpenseField.tableName,
      where: where,
      whereArgs: whereArgs,
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

  Future<void> updateAllExpense(List<Expense> expenses) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (var expense in expenses) {
        await txn.update(
          ExpenseField.tableName,
          expense.toJson(),
          where: '${ExpenseField.expenseId} = ?',
          whereArgs: [expense.expenseId],
        );
      }
    });
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
