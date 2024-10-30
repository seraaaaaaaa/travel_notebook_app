import 'package:travel_notebook/models/todo/todo_field.dart';

class Todo {
  late int? id;
  late int destinationId;
  late int categoryId;
  late String content;
  late int status; // 0 = incomplete, 1 = completed
  late int sequence;

  Todo({
    this.id,
    required this.destinationId,
    required this.categoryId,
    required this.content,
    this.status = 0,
    this.sequence = 0,
  });

  factory Todo.fromJson(Map<String, Object?> json) => Todo(
        id: json[TodoField.id] as int?,
        destinationId: json[TodoField.destinationId] as int,
        categoryId: json[TodoField.categoryId] as int,
        content: json[TodoField.content] as String,
        status: json[TodoField.status] as int,
        sequence: json[TodoField.sequence] as int,
      );

  Map<String, Object?> toJson() => {
        TodoField.id: id,
        TodoField.destinationId: destinationId,
        TodoField.categoryId: categoryId,
        TodoField.content: content,
        TodoField.status: status,
        TodoField.sequence: sequence,
      };
}
