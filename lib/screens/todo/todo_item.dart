import 'package:flutter/material.dart';
import 'package:travel_notebook/themes/constants.dart';
import 'package:travel_notebook/models/todo/todo_model.dart';
import 'package:travel_notebook/components/delete_dialog.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final int index;
  final Function() onRemove;
  final Function() onTapCheck;
  final Function(String)? onChanged;
  final Function()? onCopy;

  const TodoItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onRemove,
    required this.onTapCheck,
    required this.onChanged,
    required this.onCopy,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.todo.content);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.todo.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: null,
      confirmDismiss: (direction) async {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeleteDialog(
              title: "Remove Task",
              content: "Are you sure you want to remove this task?",
              onConfirm: () {
                Navigator.pop(context);
                widget.onRemove();
              },
              onCancel: () {
                Navigator.pop(context);
              },
            );
          },
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: kHalfPadding),
        leading: GestureDetector(
          onDoubleTap: () {
            if (widget.onCopy != null) {
              widget.onCopy!();
            }
          },
          child: ReorderableDragStartListener(
            index: widget.index,
            child: Icon(
              Icons.drag_indicator,
              color: widget.todo.status == 1
                  ? kSecondaryColor.shade300
                  : kSecondaryColor,
            ),
          ),
        ),
        title: TextFormField(
          enabled: widget.todo.status == 1 ? false : true,
          style: widget.todo.status == 1
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
          controller: _controller,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(_controller.text);
            }
          },
          // onTapOutside: (event) {
          // },
          // onFieldSubmitted: (newValue) {
          // },
          // onEditingComplete: () {
          // },
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'To-do',
              hintStyle: TextStyle(color: kGreyColor.shade400)),
        ),
        trailing: IconButton(
          icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                    turns: child.key == const ValueKey('checkIcon')
                        ? Tween<double>(begin: 1, end: 0.02).animate(anim)
                        : Tween<double>(begin: 0.02, end: 1).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
              child: widget.todo.status == 1
                  ? const Icon(
                      Icons.task_alt,
                      key: ValueKey('checkIcon'),
                      color: kPrimaryColor,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: const ValueKey('uncheckIcon'),
                      color: kGreyColor.shade500,
                    )),
          onPressed: () {
            widget.onTapCheck();
          },
        ),
      ),
    );
  }
}
