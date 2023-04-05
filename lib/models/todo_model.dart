import 'dart:convert';

class Todo {
  String user;
  String? id;
  String title;
  String description;
  String status;
  String deadline;
  String? lastModified;

  // the id and lastModified is not required because it is not determined yet
  Todo({
    required this.user,
    this.id,
    this.lastModified,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      user: json['user'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      deadline: json['deadline'] as String,
      lastModified: json['lastModified'] as String,
    );
  }

  static List<Todo> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Todo>((dynamic d) => Todo.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson(Todo todo) {
    return {
      'user': todo.user,
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'status': todo.status,
      'deadline': todo.deadline,
      'lastModified': todo.lastModified,
    };
  }
}
