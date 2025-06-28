import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_event.dart';
import 'package:travel_notebook/blocs/todo/todo_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/models/todo/enum/todo_category.dart';
import 'package:travel_notebook/models/todo/todo_model.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/components/no_data.dart';

class SelectTodo extends StatefulWidget {
  final int destinationId;

  const SelectTodo({
    super.key,
    required this.destinationId,
  });

  @override
  State<SelectTodo> createState() => _SelectTodoState();
}

class _SelectTodoState extends State<SelectTodo> {
  late TodoBloc _todoBloc;
  final TextEditingController _searchController = TextEditingController();
  String _search = "";

  late List<Todo> _selectedTodos;

  @override
  void initState() {
    super.initState();

    _selectedTodos = [];

    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.add(LoadSelectTodos(widget.destinationId));
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Map<String, List<Todo>> _groupTodosByCategory(List<Todo> todos) {
    Map<String, List<Todo>> groupedTodos = {};

    for (var todo in todos) {
      final categoryKey = todo.categoryId;
      if (groupedTodos[categoryKey.toString()] == null) {
        groupedTodos[categoryKey.toString()] = [];
      }
      if (todo.content.toLowerCase().contains(_search.toLowerCase())) {
        groupedTodos[categoryKey.toString()]!.add(todo);
      }
    }

    return groupedTodos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kHalfPadding * 3),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                kPadding, kPadding / 4, kPadding, kHalfPadding),
            child: TextFormField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              style: const TextStyle(letterSpacing: .6),
              onChanged: (textValue) {
                setState(() {
                  _search = textValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  borderSide: BorderSide(color: kGreyColor.shade200, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  borderSide: BorderSide(color: kGreyColor.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  borderSide: BorderSide(color: kGreyColor.shade200, width: 1),
                ),
                fillColor: kGreyColor[100], // Add grey background
                filled: true, // Enable fill color
                hintText: 'Search...',
                hintStyle: const TextStyle(color: kGreyColor),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: kHalfPadding, horizontal: kPadding),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: kHalfPadding * 2),
                  child: SizedBox(
                    child: Center(widthFactor: 0.0, child: Icon(Icons.search)),
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _search = "";
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      child: Center(
                          widthFactor: 0.0,
                          child: Icon(
                            Icons.close,
                            color: kGreyColor,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          children: [
            BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SelectTodoLoaded) {
                  final groupedTodos = _groupTodosByCategory(state.todos);

                  return state.todos.isEmpty
                      ? const NoData(
                          msg: 'No To-do Found', icon: Icons.check_box)
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: groupedTodos.length + state.todos.length,
                            itemBuilder: (context, index) {
                              final categoryKeys = groupedTodos.keys.toList();
                              int itemIndex = 0;

                              for (String categoryKey in categoryKeys) {
                                if (itemIndex == index) {
                                  // Return header
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: kPadding / 2),
                                    child: Text(
                                      TodoCategory.values
                                          .firstWhere((category) =>
                                              category.id ==
                                              int.parse(categoryKey))
                                          .name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: kGreyColor,
                                      ),
                                    ),
                                  );
                                }
                                itemIndex++;

                                // Check if the current item index is one of the todos under this header
                                final todoList = groupedTodos[categoryKey]!;
                                for (Todo todo in todoList) {
                                  if (itemIndex == index) {
                                    return CheckboxListTile(
                                      dense: true,
                                      checkColor: kWhiteColor,
                                      contentPadding: const EdgeInsets.all(0),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        todo.content,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      checkboxShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(kHalfPadding),
                                      ),
                                      side: const BorderSide(
                                          color: kSecondaryColor),
                                      value: todo.status == 1,
                                      onChanged: (bool? value) {
                                        if (todo.status == 1) {
                                          _selectedTodos.remove(todo);
                                        } else {
                                          _selectedTodos.add(todo);
                                        }
                                        setState(() {
                                          todo.status =
                                              todo.status == 1 ? 0 : 1;
                                        });
                                      },
                                    );
                                  }
                                  itemIndex++;
                                }
                              }

                              // Fallback in case of any mismatch
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                } else if (state is TodoError) {
                  return ErrorMsg(
                    msg: state.message,
                    onTryAgain: () => Navigator.pop(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedTodos);
                },
                child: const Text('Done'),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(top: kPadding),
                child: Text('Cancel'),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
