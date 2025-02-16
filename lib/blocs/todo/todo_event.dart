import 'package:travel_notebook/models/todo/todo_model.dart';

abstract class TodoEvent {}

class LoadTodos extends TodoEvent {
  final int destinationId;
  final int categoryId;

  LoadTodos(this.destinationId, this.categoryId);
}

class LoadSelectTodos extends TodoEvent {
  final int destinationId;

  LoadSelectTodos(this.destinationId);
}

class AddTodo extends TodoEvent {
  final Todo todo;

  AddTodo(this.todo);
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  UpdateTodo(this.todo);
}

class UpdateAllTodos extends TodoEvent {
  final List<Todo> todos;

  UpdateAllTodos(this.todos);
}

class DeleteTodo extends TodoEvent {
  final int id;
  final int destinationId;
  final int categoryId;

  DeleteTodo(this.id, this.destinationId, this.categoryId);
}
