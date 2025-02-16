import 'package:travel_notebook/models/todo/todo_model.dart';

abstract class TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  TodoLoaded(this.todos);
}

class TodoError extends TodoState {
  final String message;

  TodoError(this.message);
}

class SelectTodoLoaded extends TodoState {
  final List<Todo> todos;

  SelectTodoLoaded(this.todos);
}
