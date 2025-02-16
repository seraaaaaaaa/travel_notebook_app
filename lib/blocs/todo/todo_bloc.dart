import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_event.dart';
import 'package:travel_notebook/blocs/todo/todo_state.dart';
import 'package:travel_notebook/blocs/todo/todo_service.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoService todoService;

  TodoBloc(this.todoService) : super(TodoLoading()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoLoading());
      try {
        final todos =
            await todoService.readAll(event.destinationId, event.categoryId);

        emit(TodoLoaded(todos));
      } catch (e) {
        emit(TodoError('Failed to load To-do list'));
      }
    });

    on<LoadSelectTodos>((event, emit) async {
      emit(TodoLoading());
      try {
        final todos = await todoService.readAllIncomplete(event.destinationId);

        emit(SelectTodoLoaded(todos));
      } catch (e) {
        emit(TodoError('Failed to load To-do list'));
      }
    });

    on<AddTodo>((event, emit) async {
      try {
        await todoService.create(event.todo);

        add(LoadTodos(event.todo.destinationId, event.todo.categoryId));
      } catch (e) {
        emit(TodoError('Failed to add to-do'));
      }
    });

    on<UpdateTodo>((event, emit) async {
      try {
        await todoService.update(event.todo);

        // add(LoadTodos(event.todo.destinationId));
      } catch (e) {
        emit(TodoError('Failed to update to-do'));
      }
    });

    on<UpdateAllTodos>((event, emit) async {
      try {
        await todoService.updateAll(event.todos);

        // add(LoadTodos(event.destinationId));
      } catch (e) {
        emit(TodoError('Failed to update to-dos'));
      }
    });

    on<DeleteTodo>((event, emit) async {
      try {
        await todoService.delete(event.id);

        add(LoadTodos(event.destinationId, event.categoryId));
      } catch (e) {
        emit(TodoError('Failed to delete to-do'));
      }
    });
  }
}
