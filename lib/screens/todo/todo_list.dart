import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_bloc.dart';
import 'package:travel_notebook/blocs/destination/destination_state.dart';
import 'package:travel_notebook/blocs/todo/todo_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_event.dart';
import 'package:travel_notebook/blocs/todo/todo_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/models/destination/destination_model.dart';
import 'package:travel_notebook/models/todo/enum/todo_category.dart';
import 'package:travel_notebook/models/todo/todo_model.dart';
import 'package:travel_notebook/screens/todo/category_item.dart';
import 'package:travel_notebook/services/debouncer.dart';
import 'package:travel_notebook/components/no_data.dart';
import 'package:travel_notebook/components/section_title.dart';
import 'package:travel_notebook/screens/todo/todo_item.dart';

class TodoList extends StatefulWidget {
  final Destination destination;

  const TodoList({super.key, required this.destination});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _debouncer = Debouncer(milliseconds: 300);

  late Destination _destination;
  late TodoBloc _todoBloc;

  int _categoryId = 0;

  @override
  void initState() {
    _destination = widget.destination;

    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.add(LoadTodos(_destination.destinationId!, _categoryId));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshPage() async {
    _todoBloc.add(LoadTodos(_destination.destinationId!, _categoryId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationUpdated) {
            setState(() {
              _destination = state.destination;
            });
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            onRefresh: _refreshPage,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: 'To-do List',
                    btnText: 'Add',
                    btnAction: () {
                      FocusScope.of(context).unfocus();
                      _todoBloc.add(AddTodo(Todo(
                          destinationId: _destination.destinationId!,
                          content: '',
                          sequence: -1,
                          categoryId: _categoryId)));
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TodoCategory.values.map((category) {
                        return CategoryItem(
                          categoryId: category.id,
                          categoryName: category.name,
                          selected: _categoryId == category.id,
                          onTap: () {
                            setState(() {
                              _categoryId = category.id;
                            });
                            _refreshPage();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      if (state is TodoLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TodoLoaded) {
                        return state.todos.isEmpty
                            ? const NoData(
                                msg: 'No To-do List', icon: Icons.check_box)
                            : ReorderableListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                buildDefaultDragHandles:
                                    false, // Disable the default drag handles
                                onReorder: (int oldIndex, int newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    final todo = state.todos.removeAt(oldIndex);
                                    state.todos.insert(newIndex, todo);

                                    for (int i = 0;
                                        i < state.todos.length;
                                        i++) {
                                      state.todos[i].sequence = i;
                                    }
                                  });
                                  _todoBloc.add(UpdateAllTodos(state.todos));
                                },
                                children:
                                    List.generate(state.todos.length, (index) {
                                  final todo = state.todos[index];
                                  return Container(
                                    key: Key(todo.id.toString()),
                                    child: TodoItem(
                                      todo: todo,
                                      index: index,
                                      onRemove: () {
                                        _todoBloc.add(DeleteTodo(
                                          todo.id!,
                                          _destination.destinationId!,
                                          _categoryId,
                                        ));
                                      },
                                      onTapCheck: () {
                                        setState(() {
                                          todo.status =
                                              todo.status == 1 ? 0 : 1;
                                        });
                                        _todoBloc.add(UpdateTodo(todo));
                                      },
                                      onChanged: (val) {
                                        _debouncer.run(() {
                                          todo.content = val;
                                          _todoBloc.add(UpdateTodo(todo));
                                        });
                                      },
                                    ),
                                  );
                                }),
                              );
                      } else if (state is TodoError) {
                        return ErrorMsg(
                          msg: state.message,
                          onTryAgain: () => _refreshPage(),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
