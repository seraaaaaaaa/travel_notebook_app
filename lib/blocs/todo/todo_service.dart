import 'package:travel_notebook/models/todo/todo_model.dart';
import 'package:travel_notebook/models/todo/todo_field.dart';
import 'package:travel_notebook/services/database_helper.dart';

class TodoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Todo>> readAll(int destinationId, int categoryId) async {
    final db = await _databaseHelper.database;
    const orderBy = '${TodoField.sequence} ASC, ${TodoField.id} DESC';

    final result = await db.query(
      TodoField.tableName,
      where: '${TodoField.destinationId} = ? AND ${TodoField.categoryId} = ?',
      whereArgs: [destinationId, categoryId],
      orderBy: orderBy,
    );
    return result.map((json) => Todo.fromJson(json)).toList();
  }

  Future<List<Todo>> readAllIncomplete(int destinationId) async {
    final db = await _databaseHelper.database;
    const orderBy = '${TodoField.sequence} ASC, ${TodoField.categoryId} DESC';

    var where = '${TodoField.destinationId} = ? AND ${TodoField.status} = ?';
    List<dynamic> whereArgs = [destinationId, 0];

    final result = await db.query(
      TodoField.tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return result.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> create(Todo todo) async {
    final db = await _databaseHelper.database;
    await db.insert(TodoField.tableName, todo.toJson());
  }

  Future<void> update(Todo todo) async {
    final db = await _databaseHelper.database;

    await db.update(
      TodoField.tableName,
      todo.toJson(),
      where: '${TodoField.id} = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> updateAll(List<Todo> todos) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (var todo in todos) {
        await txn.update(
          TodoField.tableName,
          todo.toJson(),
          //  {'sequence': todo.sequence},
          where: '${TodoField.id} = ?',
          whereArgs: [todo.id],
        );
      }
    });
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;

    await db.delete(
      TodoField.tableName,
      where: '${TodoField.id} = ?',
      whereArgs: [id],
    );
  }
}
