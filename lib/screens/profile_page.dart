import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// will display the profile page
// this profile page is dynamic, it can also display the profile page of other user
// the final isYou determine wheter is the profile is yours or your friends
class ProfilePage extends StatefulWidget {
  final userData;
  final isYou;
  const ProfilePage({super.key, required this.userData, required this.isYou});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> friends =
        context.watch<AuthProvider>().friends(widget.userData['id']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.isYou)
              ? 'My Profile'
              : "${widget.userData['firstName']}'s Profile",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('ID: ${widget.userData['id']}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                'Name: ${widget.userData['firstName']} ${widget.userData['lastName']}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Birthday: ${widget.userData['birthday']}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Location: ${widget.userData['location']}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (widget.isYou && widget.userData['bio'].isEmpty)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bio: ${widget.userData['bio']}'),
                      ElevatedButton(
                        onPressed: () {
                          // alertdialog will pop, with bio field
                          TextEditingController bioController =
                              TextEditingController();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Add Bio'),
                                  content: TextFormField(
                                    controller: bioController,
                                    decoration: const InputDecoration(
                                      labelText: 'Bio',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // call context addbio
                                        context
                                            .read<AuthProvider>()
                                            .addBio(bioController.text);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text('Added a bio')));
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: const Text('Add Bio'),
                      ),
                    ],
                  )
                : Text('Bio: ${widget.userData['bio']}'),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: friends,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Friends',
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
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      // go to the profile of the tapped user
                                      if (widget.isYou == false) {
                                        Navigator.of(context).pop();
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            userData: data,
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
                                      trailing: (widget.isYou)
                                          ? ElevatedButton(
                                              onPressed: () async {
                                                final result = await context
                                                    .read<AuthProvider>()
                                                    .removeFriend(data['id']);

                                                if (result != null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              Text(result)));
                                                }
                                              },
                                              child: const Text('Remove'))
                                          : null,
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
            },
          ),
        ],
      ),
    );
  }
}
