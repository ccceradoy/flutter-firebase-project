import 'package:flutter/material.dart';

// display all the info in the notification array of the currently logged in user
class NotificationPage extends StatelessWidget {
  final userData;
  const NotificationPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    if (userData['notification'].length == 0) {
      return const Center(
        child: Text('No Notification'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Notifications',
            style: TextStyle(fontSize: 25),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: userData['notification'].length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {},
              child: ListTile(
                title: Text(userData['notification'][index]),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
