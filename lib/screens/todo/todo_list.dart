import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';
import 'package:travel_notebook/blocs/todo/todo_bloc.dart';
import 'package:travel_notebook/blocs/todo/todo_event.dart';
import 'package:travel_notebook/blocs/todo/todo_state.dart';
import 'package:travel_notebook/components/error_msg.dart';
import 'package:travel_notebook/models/todo/enum/todo_category.dart';
import 'package:travel_notebook/models/todo/todo_model.dart';
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

class _TodoListState extends State<TodoList> with TickerProviderStateMixin {
  late TabController _tabController;

  final _debouncer = Debouncer(milliseconds: 300);

  late int _destinationId;
  late TodoBloc _todoBloc;

  int _categoryId = 0;
  int _latestSeq = 0;

  final ScrollController _scrollController = ScrollController();
  bool _hideDone = false;

  @override
  void initState() {
    super.initState();

    _destinationId = widget.destinationId;

    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.add(LoadTodos(_destinationId, _categoryId));

    _tabController =
        TabController(length: TodoCategory.values.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _categoryId = TodoCategory.values[_tabController.index].id;
      });

      if (_tabController.indexIsChanging) {
        _scrollToTop();
        _refreshPage();
      }
    });
  }

  Future<void> _refreshPage() async {
    _todoBloc.add(LoadTodos(_destinationId, _categoryId));
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      -1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHalfPadding / 2),
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kHalfPadding),
                child: SectionTitle(
                  title: 'To-do List',
                  extraWidget: InkWell(
                      onTap: () {
                        setState(() {
                          _hideDone = !_hideDone;
                        });
                      },
                      child: Icon(
                          !_hideDone
                              ? Icons.done_all_outlined
                              : Icons.remove_done_outlined,
                          color: _hideDone ? kSecondaryColor : kPrimaryColor)),
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
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  dividerHeight: 0, // Removes the bottom divider
                  tabAlignment: TabAlignment.start, // Removes left padding
                  indicator: const RoundUnderlineTabIndicator(),
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  tabs: TodoCategory.values.map((category) {
                    return Tab(text: category.name);
                  }).toList(),
                  labelColor: kBlackColor,
                  unselectedLabelColor: kGreyColor,
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: kHalfPadding),
                ),
              ),
            ),
          ],
          body: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TodoLoaded) {
                _latestSeq =
                    state.todos.isNotEmpty ? state.todos.last.sequence + 1 : 0;

                String msg = TodoCategory.values[_categoryId].msg;

                return state.todos.isEmpty
                    ? NoData(msg: msg, icon: Icons.check_box)
                    : Padding(
                        padding: const EdgeInsets.all(kHalfPadding / 2),
                        child: CustomScrollView(
                          slivers: [
                            ReorderableSliverList(
                              delegate: ReorderableSliverChildBuilderDelegate(
                                (context, index) {
                                  final todo = state.todos[index];
                                  return _hideDone && todo.status == 1
                                      ? const SizedBox.shrink()
                                      : Container(
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
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    _todoBloc.add(AddTodo(Todo(
                                                        destinationId:
                                                            _destinationId,
                                                        content: todo.content,
                                                        sequence:
                                                            todo.sequence + 1,
                                                        categoryId:
                                                            _categoryId)));
                                                  },
                                          ),
                                        );
                                },
                                childCount: state.todos.length,
                              ),
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final todo = state.todos.removeAt(oldIndex);
                                  state.todos.insert(newIndex, todo);

                                  for (int i = 0; i < state.todos.length; i++) {
                                    state.todos[i].sequence = i;
                                  }
                                });
                                _todoBloc.add(UpdateAllTodos(state.todos));
                              },
                            ),
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(kPadding,
                                    kHalfPadding / 2, kPadding, kPadding * 2),
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
                            ),
                          ],
                        ),
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
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: kWhiteColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class RoundUnderlineTabIndicator extends Decoration {
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;

  const RoundUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 5.0, color: kPrimaryColor),
    this.insets = const EdgeInsets.symmetric(horizontal: kHalfPadding),
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundUnderlinePainter(this, onChanged);
  }
}

class _RoundUnderlinePainter extends BoxPainter {
  final RoundUnderlineTabIndicator decoration;

  _RoundUnderlinePainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final EdgeInsets insets = decoration.insets.resolve(textDirection);
    final Rect indicator = insets.deflateRect(rect);

    const double indicatorWidth = 40.0;
    final double centerX = (indicator.left + indicator.right) / 2;
    final double left = centerX - indicatorWidth / 2;
    final double right = centerX + indicatorWidth / 2;
    final double bottom = indicator.bottom - decoration.borderSide.width;

    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
  }
}
