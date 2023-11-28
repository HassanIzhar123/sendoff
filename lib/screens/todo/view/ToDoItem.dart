
import 'package:flutter/material.dart';
import 'package:sendoff/models/Search/todo_save_model.dart';

class ToDoItem extends StatefulWidget {
  final int index;
  final List<ToDoSaveModel> todoList;
  final Function(bool check, int index) onChecked;

  const ToDoItem({super.key, required this.index, required this.todoList, required this.onChecked});

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool isChecked = false;

  @override
  void initState() {
    isChecked = widget.todoList[widget.index].isDone;
    //log"initState: ${widget.todoList[widget.index].isDone}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: widget.index != 0 ? 10.0 : 0.0,
      ),
      padding: const EdgeInsets.only(
        left: 10.0,
        top: 5.0,
        bottom: 5.0,
        right: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE6E6E6),
          width: 2.0,
          style: BorderStyle.solid,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: const Color(0xFF8F99AC),
            ),
            child: Checkbox(
              shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              value: isChecked,
              onChanged: (bol) {
                setState(() {
                  isChecked = bol!;
                  widget.onChecked(isChecked, widget.index);
                });
              },
              checkColor: Colors.white,
            ),
          ),
          Text(
            widget.todoList[widget.index].taskName,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
