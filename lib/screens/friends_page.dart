import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/providers/auth_provider.dart';
import 'package:final_project/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:provider/provider.dart';

// this page displays the user who is available to be added
// and the users you added you
class FriendsPage extends StatefulWidget {
  final userData;
  const FriendsPage({super.key, required this.userData});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const FriendRequest(),
      OtherPeople(
        userData: widget.userData,
      ),
    ]);
  }
}

class FriendRequest extends StatefulWidget {
  const FriendRequest({super.key});

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> receivedRequests =
        context.watch<AuthProvider>().receivedRequests;
    return StreamBuilder<QuerySnapshot>(
        stream: receivedRequests,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.length == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Friend Requests',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Center(
                  child: Text('No Friend Request'),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Friend Requests',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      if (data.isEmpty) {
                        return const Center(
                          child: Text("No Friend Request Found"),
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  // go to the profile of the tapped user
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
                                        '${data['firstName']} ${data['lastName']}',
                                    radius: 31,
                                    fontsize: 21,
                                  ),
                                  title: Text(
                                      '${data['firstName']} ${data['lastName']}'),
                                  // '${data['id']}'),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      final result = await context
                                          .read<AuthProvider>()
                                          .acceptFriend(data['id']);

                                      if (result != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(result)));
                                      }
                                    },
                                    child: const Text('Accept'),
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
              ),
            ],
          );
        });
  }
}

class OtherPeople extends StatefulWidget {
  final userData;
  const OtherPeople({super.key, required this.userData});

  @override
  State<OtherPeople> createState() => _OtherPeopleState();
}

class _OtherPeopleState extends State<OtherPeople> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> x = context.watch<AuthProvider>().notFriends(
        widget.userData['id'],
        widget.userData['friends'],
        widget.userData['receivedRequest'],
        widget.userData['sentRequest']);
    return StreamBuilder<QuerySnapshot>(
      stream: x,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.docs.length == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'People You May know',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Center(
                child: Text('No People to Add'),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'People You May know',
                style: TextStyle(fontSize: 25),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Row(
                      children: [
                        ToAddWidget(data: data),
                      ],
                    );
                  })
                  .toList()
                  .cast(),
            ),
          ],
        );
      },
    );
  }
}

class ToAddWidget extends StatefulWidget {
  final data;
  const ToAddWidget({super.key, required this.data});

  @override
  State<ToAddWidget> createState() => _ToAddWidgetState();
}

class _ToAddWidgetState extends State<ToAddWidget> {
  bool _isClicked = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            // go to the profile of the tapped user
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userData: widget.data,
                  isYou: false,
                ),
              ),
            );
          },
          child: ListTile(
            leading: ProfilePicture(
              name: '${widget.data['firstName']} ${widget.data['lastName']}',
              radius: 31,
              fontsize: 21,
            ),
            title:
                Text('${widget.data['firstName']} ${widget.data['lastName']}'),
            // '${data['id']}'),
            trailing: ElevatedButton(
              onPressed: () async {
                final result = await context
                    .read<AuthProvider>()
                    .addFriend(widget.data['id']);

                setState(() {
                  _isClicked = true;
                });

                if (result != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: Text((_isClicked == true) ? 'Added' : 'Add'),
            ),
          ),
        ),
      ),
    );
  }
}
