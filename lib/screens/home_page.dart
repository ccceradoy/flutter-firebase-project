import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/todo_model.dart';
import 'package:final_project/providers/todo_provider.dart';
import 'package:final_project/screens/friends_page.dart';
import 'package:final_project/screens/notif_page.dart';
import 'package:final_project/screens/profile_page.dart';
import 'package:final_project/screens/todo_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  final userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        userData: widget.userData,
                        isYou: true,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProfilePicture(
                        name:
                            '${widget.userData['firstName']} ${widget.userData['lastName']}',
                        radius: 31,
                        fontsize: 21,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${widget.userData['firstName']} ${widget.userData['lastName']}'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logOut();
                  Navigator.pop(context);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(
                    userData: widget.userData,
                    isYou: true), // for the search function
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
        // the routes
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.people)),
            Tab(icon: Icon(Icons.notifications))
          ],
        ),
        title: const Text('Welcome'),
      ),
      body: TabBarView(
        children: [
          HomePageTodos(
            userData: widget.userData,
          ),
          FriendsPage(userData: widget.userData),
          NotificationPage(userData: widget.userData),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return TodoModal(
                  userData: widget.userData,
                  toEdit: false,
                  isYou: true,
                );
              });
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}

// a responsive search that wil be placed on the appbar of its parent.
// when a query is clicked, it will go to the profile of that clicked query/user
class MySearchDelegate extends SearchDelegate {
  final userData;
  final isYou;
  List<dynamic> x = [];
  MySearchDelegate({required this.userData, required this.isYou});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        query,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Stream<QuerySnapshot> friends =
        context.watch<AuthProvider>().friends(userData['id']);
    return StreamBuilder<QuerySnapshot>(
      stream: friends,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            if (document['firstName'].toLowerCase().contains(query) ||
                document['lastName'].toLowerCase().contains(query)) {
              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          // go to the profile of the tapped user
                          if (isYou == false) {
                            Navigator.of(context).pop();
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userData: document,
                                isYou: false,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: ProfilePicture(
                            name:
                                '${document['firstName']} ${document['lastName']}',
                            radius: 31,
                            fontsize: 21,
                          ),
                          title: Text(
                              '${document['firstName']} ${document['lastName']}'),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Row();
          },
        );
      },
    );
  }
}

// will display all the todos of you and your friends, as well as a floatingActionButton for creating new todos
class HomePageTodos extends StatefulWidget {
  final userData;
  const HomePageTodos({super.key, required this.userData});

  @override
  State<HomePageTodos> createState() => _HomePageTodosState();
}

class _HomePageTodosState extends State<HomePageTodos> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _todos = context
        .watch<TodoListProvider>()
        .getTodos(widget.userData['id'], widget.userData['friends']);
    return StreamBuilder<QuerySnapshot>(
        stream: _todos,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {},
                            child: ListTile(
                              title: TodoCard(
                                data: data,
                                userData: widget.userData,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                })
                .toList()
                .cast(),
          );
        });
  }
}

// each todo will be represented in this widget
// it is dynamic, when you click the option of a todo that is not yours, you can only see edit
// but when you click the option of your todo, you can see edit and delete option
class TodoCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final userData;
  const TodoCard({super.key, required this.data, required this.userData});

  @override
  State<TodoCard> createState() => _TodoCardState();
}

enum TodoOption { Edit, Delete }

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${widget.data['title']}',
              style: const TextStyle(fontSize: 25),
            ),
            Text('Desription: ${widget.data['description']}'),
            Text('Status: ${widget.data['status']}'),
            Text('Deadline: ${widget.data['deadline']}'),
            Text('Last Modified: ${widget.data['lastModified']}'),
          ],
        ),
        PopupMenuButton<TodoOption>(
          itemBuilder: (context) {
            if (widget.data['user'] == widget.userData['id']) {
              return [
                const PopupMenuItem(
                  child: Text('Edit'),
                  value: TodoOption.Edit,
                ),
                const PopupMenuItem(
                  child: Text('Delete'),
                  value: TodoOption.Delete,
                ),
              ];
            } else {
              return [
                const PopupMenuItem(
                  child: Text('Edit'),
                  value: TodoOption.Edit,
                ),
              ];
            }
          },
          onSelected: (value) {
            Todo todo = Todo.fromJson(widget.data);
            context.read<TodoListProvider>().changeSelectedTodo(todo);
            if (value == TodoOption.Edit) {
              // reshow the modal
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TodoModal(
                      userData: widget.userData,
                      toEdit: true,
                      data: widget.data,
                      isYou: widget.data['user'] == widget.userData['id'],
                    );
                  });
            } else {
              context.read<TodoListProvider>().deleteTodo();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Todo Deleted')));
            }
          },
        ),
      ],
    );
  }
}
