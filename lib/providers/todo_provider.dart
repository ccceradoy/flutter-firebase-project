import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/api/firebase_todo.dart';
import 'package:final_project/models/todo_model.dart';
import 'package:flutter/cupertino.dart';

class TodoListProvider with ChangeNotifier {
  late FirebaseTodoAPI firebaseService;
  late Stream<QuerySnapshot> _todosStream;
  Todo? _selectedTodo;

  TodoListProvider() {
    firebaseService = FirebaseTodoAPI();
    fetchTodos();
  }

  // getter
  Stream<QuerySnapshot> get todos => _todosStream;
  Todo get selected => _selectedTodo!;

  Stream<QuerySnapshot> getTodos(String userId, List friends) {
    return firebaseService.getTodos(userId, friends);
  }

  changeSelectedTodo(Todo item) {
    _selectedTodo = item;
  }

  void fetchTodos() async {
    _todosStream = await firebaseService.getAllTodos();
    notifyListeners();
  }

  void addTodo(Todo item) async {
    String message = await firebaseService.addTodo(item.toJson(item));
    print(message);
    notifyListeners();
  }

  void editTodo(Map<String, dynamic> todoField) async {
    String message = await firebaseService.editTodo(todoField);
    print(message);
    notifyListeners();
  }

  void deleteTodo() async {
    String message = await firebaseService.deleteTodo(
        _selectedTodo!.id, _selectedTodo!.user);
    print(message);
    notifyListeners();
  }
}
