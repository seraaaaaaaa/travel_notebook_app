import 'package:travel_notebook/models/destination/destination_field.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/expense/expense_field.dart';
import 'package:travel_notebook/services/database_helper.dart';

class DestinationService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Destination>> readAllDestinations() async {
    final db = await _databaseHelper.database;
    const orderBy =
        '${DestinationField.isPin} DESC, ${DestinationField.startDate} DESC';
    final result = await db.query(DestinationField.tableName, orderBy: orderBy);

    return result.map((json) => Destination.fromJson(json)).toList();
  }

  Future<Destination> readDestination(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DestinationField.tableName,
      columns: DestinationField.values,
      where: '${DestinationField.destinationId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Destination.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<String> createDestination(Destination destination) async {
    final db = await _databaseHelper.database;
    final id =
        await db.insert(DestinationField.tableName, destination.toJson());

    if (id > 0) {
      return 'Destination added successfully';
    } else {
      return 'Failed to add destination';
    }
  }

  Future<String> updateDestination(Destination destination) async {
    final db = await _databaseHelper.database;
    final result = await db.update(
      DestinationField.tableName,
      destination.toJson(),
      where: '${DestinationField.destinationId} = ?',
      whereArgs: [destination.destinationId],
    );

    if (result > 0) {
      return 'Destination updated successfully';
    } else {
      return 'Failed to update destination';
    }
  }

  Future<String> deleteDestination(int destinationId) async {
    final db = await _databaseHelper.database;

    // delete all its expenses as well
    await db.delete(
      ExpenseField.tableName,
      where: '${ExpenseField.destinationId} = ?',
      whereArgs: [destinationId],
    );

    int result = await db.delete(
      DestinationField.tableName,
      where: '${DestinationField.destinationId} = ?',
      whereArgs: [destinationId],
    );

    if (result > 0) {
      return 'Destination deleted successfully';
    } else {
      return 'Failed to delete destination';
    }
  }
}
