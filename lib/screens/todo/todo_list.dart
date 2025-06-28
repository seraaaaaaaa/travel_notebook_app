import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_event.dart';
import 'package:travel_notebook/blocs/todo/todo_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/models/todo/enum/todo_category.dart';
import 'package:travel_notebook/models/todo/todo_model.dart';
import 'package:travel_notebook/screens/todo/category_item.dart';
import 'package:travel_notebook/services/debouncer.dart';
import 'package:travel_notebook/components/no_data.dart';
import 'package:travel_notebook/components/section_title.dart';
import 'package:travel_notebook/screens/todo/todo_item.dart';
import 'package:travel_notebook/themes/constants.dart';

class TodoList extends StatefulWidget {
  final int destinationId;

  const TodoList({super.key, required this.destinationId});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _debouncer = Debouncer(milliseconds: 300);

  late int _destinationId;
  late TodoBloc _todoBloc;

  int _categoryId = 0;
  int _latestSeq = 0;

  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {}; // Store keys for each category
  double _indicatorLeft = 17.0;
  double _indicatorWidth = 38.0; // Default width

  @override
  void initState() {
    super.initState();

    _destinationId = widget.destinationId;

    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.add(LoadTodos(_destinationId, _categoryId));

    // Initialize keys for tracking each category size
    for (var category in TodoCategory.values) {
      _itemKeys[category.id] = GlobalKey();
    }

    // Delay to allow layout completion, then calculate size
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _updateIndicatorPosition();
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshPage() async {
    _todoBloc.add(LoadTodos(_destinationId, _categoryId));
  }

  /// Updates the underline position dynamically based on category size
  void _updateIndicatorPosition() {
    if (!mounted) return;

    final selectedKey = _itemKeys[_categoryId];
    if (selectedKey == null) return;

    final RenderBox? renderBox =
        selectedKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);

      setState(() {
        _indicatorWidth =
            size.width * 0.5; // Adjust width dynamically (60% of text width)

        _indicatorLeft = position.dx +
            (size.width / 3.8) -
            (_indicatorWidth / 2); // Center the underline
      });

      // Auto-scroll to keep the selected category visible
      _scrollController.animateTo(
        _indicatorLeft - 20, // Scroll a bit before the selected category
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'To-do List',
                btnText: 'Add',
                btnAction: () {
                  FocusScope.of(context).unfocus();

                  _todoBloc.add(AddTodo(Todo(
                      destinationId: _destinationId,
                      content: '',
                      sequence: -1,
                      categoryId: _categoryId)));
                },
              ),
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Stack(
                  children: [
                    Row(
                      children: TodoCategory.values.map((category) {
                        return CategoryItem(
                          categoryId: category.id,
                          categoryName: category.name,
                          selected: _categoryId == category.id,
                          itemKey: _itemKeys[category.id]!,
                          onTap: () {
                            setState(() {
                              _categoryId = category.id;
                            });

                            _updateIndicatorPosition();
                            _refreshPage();
                          },
                        );
                      }).toList(),
                    ),
                    // Sliding underline animation
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _indicatorLeft, // Dynamically updated
                      bottom: 0,
                      child: Container(
                        width: _indicatorWidth, // Dynamic width
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TodoLoaded) {
                    _latestSeq = state.todos.isNotEmpty
                        ? state.todos.last.sequence + 1
                        : 0;

                    String msg = TodoCategory.values[_categoryId].msg;

                    return state.todos.isEmpty
                        ? NoData(msg: msg, icon: Icons.check_box)
                        : Column(
                            children: [
                              ReorderableListView(
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
                                          _destinationId,
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
                                      onCopy: todo.status == 1
                                          ? null
                                          : () {
                                              FocusScope.of(context).unfocus();
                                              _todoBloc.add(AddTodo(Todo(
                                                  destinationId: _destinationId,
                                                  content: todo.content,
                                                  sequence: todo.sequence,
                                                  categoryId: _categoryId)));
                                            },
                                    ),
                                  );
                                }),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: kPadding,
                                    vertical: kHalfPadding / 2),
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    _todoBloc.add(AddTodo(Todo(
                                        destinationId: _destinationId,
                                        content: '',
                                        sequence: _latestSeq,
                                        categoryId: _categoryId)));
                                  },
                                  child: const Text('Add'),
                                ),
                              ),
                            ],
                          );
                  } else if (state is TodoError) {
                    return ErrorMsg(
                      msg: state.message,
                      onTryAgain: () => _refreshPage(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
