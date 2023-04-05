import 'package:final_project/models/todo_model.dart';
import 'package:final_project/providers/todo_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// display the todo alertdialog
// this is also dynamic, if this is clicked by your friends,
// then the status cannot be changed because only you can change the status
// if edit is clicked, then the fields are filled with the current value of the todo
// otherwise, the fields are empty
class TodoModal extends StatefulWidget {
  final userData;
  final toEdit;
  final data;
  final isYou;
  const TodoModal(
      {super.key,
      required this.userData,
      required this.toEdit,
      this.data,
      required this.isYou});

  @override
  State<TodoModal> createState() => _TodoModalState();
}

class _TodoModalState extends State<TodoModal> {
  final TextEditingController titleControllerNew = TextEditingController();
  final TextEditingController descriptionControllerNew =
      TextEditingController();
  final TextEditingController deadlineControllerNew = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey();
  static final List<String> _dropdownOptions = [
    'Not Yet Started',
    'Done',
    'On Progress',
  ];

  String statusValueNew = _dropdownOptions.first;

  late TextEditingController titleControllerEdit;
  late TextEditingController descriptionControllerEdit;
  late TextEditingController deadlineControllerEdit;
  late String statusValueEdit;

  bool repeatStatus = true;

  @override
  Widget build(BuildContext context) {
    if (widget.toEdit && repeatStatus) {
      titleControllerEdit = TextEditingController(text: widget.data['title']);
      descriptionControllerEdit =
          TextEditingController(text: widget.data['description']);
      deadlineControllerEdit =
          TextEditingController(text: widget.data['deadline']);

      if (widget.isYou) {
        statusValueEdit = widget.data['status'];
      }
    }

    return AlertDialog(
      content: Form(
        key: _key,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  (widget.toEdit == true) ? 'Edit Todo' : 'New Todo',
                  style: const TextStyle(fontSize: 25),
                ),
              ],
            ),
            TextFormField(
              controller:
                  (widget.toEdit) ? titleControllerEdit : titleControllerNew,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextFormField(
              controller: (widget.toEdit)
                  ? descriptionControllerEdit
                  : descriptionControllerNew,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: (widget.toEdit)
                  ? deadlineControllerEdit
                  : deadlineControllerNew,
              decoration: const InputDecoration(
                labelText: 'Deadline',
              ),
              onTap: () async {
                DateTime? deadline = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(3000),
                );

                if (deadline != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(deadline);
                  setState(() {
                    if (widget.toEdit) {
                      deadlineControllerEdit.text = formattedDate;
                    } else {
                      deadlineControllerNew.text = formattedDate;
                    }
                  });
                }
              },
            ),
            (widget.isYou)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Status",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          FormField<String>(
                              builder: (FormFieldState<String> state) {
                            return DropdownButton<String>(
                              value: (widget.toEdit)
                                  ? statusValueEdit
                                  : statusValueNew,
                              onChanged: (String? value) {
                                setState(() {
                                  if (widget.toEdit) {
                                    statusValueEdit = value!;
                                    repeatStatus = false;
                                  } else {
                                    statusValueNew = value!;
                                  }
                                });
                              },
                              items: _dropdownOptions
                                  .map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            );
                          }),
                        ],
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Text('Status: '),
                        Text("${widget.data['status']}"),
                      ],
                    ),
                  )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (widget.toEdit == true &&
                titleControllerEdit.text != '' &&
                descriptionControllerEdit.text != '' &&
                deadlineControllerEdit.text != '') {
              Map<String, dynamic> editedTodo = {
                'id': widget.data['id'],
                'title': titleControllerEdit.text,
                'description': descriptionControllerEdit.text,
                'lastModified':
                    '${DateFormat('yyyy-MM-dd').format(DateTime.now())} @ ${DateFormat.jm().format(DateTime.now())}',
                'deadline': deadlineControllerEdit.text,
                'user': widget.data['user'],
              };
              if (widget.isYou) {
                editedTodo['status'] = statusValueEdit;
              } else {
                editedTodo['status'] = widget.data['status'];
              }

              context.read<TodoListProvider>().editTodo(editedTodo);
              // send a notification here to the

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Edited a todo')));
              Navigator.of(context).pop();
            } else if (widget.toEdit == false &&
                titleControllerNew.text != '' &&
                descriptionControllerNew.text != '' &&
                deadlineControllerNew.text != '') {
              Todo newTodo = Todo(
                user: widget.userData['id'],
                title: titleControllerNew.text,
                description: descriptionControllerNew.text,
                status: statusValueNew,
                deadline: deadlineControllerNew.text,
                lastModified:
                    '${DateFormat('yyyy-MM-dd').format(DateTime.now())} @ ${DateFormat.jm().format(DateTime.now())}',
              );
              context.read<TodoListProvider>().addTodo(newTodo);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added new todo')));
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')));
            }
          },
          child: (widget.toEdit) ? const Text('Save') : const Text('Add'),
        ),
      ],
    );
  }
}
