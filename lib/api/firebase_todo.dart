import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTodoAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> addTodo(Map<String, dynamic> todo) async {
    try {
      final docRef = await db.collection('todos').add(todo);
      await db.collection('todos').doc(docRef.id).update({'id': docRef.id});

      // append the todos id in the user's todos: []
      final userDocRef = db.collection('users').doc(todo['user']);
      userDocRef.get().then(
        (DocumentSnapshot doc) async {
          final data = doc.data() as Map<String, dynamic>;

          await userDocRef.update({
            'todos': [...data['todos'], docRef.id]
          });
        },
        onError: (e) => print("Error getting document: $e"),
      );

      return "Successfully added todo!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Stream<QuerySnapshot> getAllTodos() {
    return db.collection("todos").snapshots();
  }

  // get all you and your friends todos
  Stream<QuerySnapshot> getTodos(String userId, List friends) {
    return db
        .collection('todos')
        .where('user', whereIn: [userId, ...friends]).snapshots();
  }

  Future<String> editTodo(Map<String, dynamic> todo) async {
    try {
      final docRef = await db.collection('todos').doc(todo['id']);

      await docRef.update({'deadline': todo['deadline']});
      await docRef.update({'description': todo['description']});
      await docRef.update({'lastModified': todo['lastModified']});
      await docRef.update({'status': todo['status']});
      await docRef.update({'title': todo['title']});

      // friend is editing your todo
      if (todo['user'] != auth.currentUser!.uid) {
        final todoOwner = db.collection('users').doc(todo['user']);
        await todoOwner.get().then(
          (DocumentSnapshot doc) async {
            final data = doc.data() as Map<String, dynamic>;
            final whoEdited = db.collection('users').doc(auth.currentUser!.uid);

            await whoEdited.get().then((DocumentSnapshot docu) async {
              final whoEditedData = docu.data() as Map<String, dynamic>;

              data['notification'].add(
                  "${whoEditedData['firstName']} ${whoEditedData['lastName']} edited todo titled ${todo['title']} @ ${todo['lastModified']}");
            });

            // the array should only have 10 max notifs
            if (data['notification'].length > 10) {
              data['notification'].removeAt(0);
            }

            await todoOwner.update({'notification': data['notification']});
          },
          onError: (e) => print("Error getting document: $e"),
        );
      }

      return "Successfully edited todo!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteTodo(String? id, String? userId) async {
    try {
      await db.collection("todos").doc(id).delete();

      // unbind the todos in the user's todolist
      final userDocRef = db.collection('users').doc(userId);
      userDocRef.get().then(
        (DocumentSnapshot doc) async {
          final data = doc.data() as Map<String, dynamic>;
          data['todos'].remove(id);
          await userDocRef.update({
            'todos': data['todos'],
          });
        },
        onError: (e) => print("Error getting document: $e"),
      );

      return "Successfully deleted todo!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}
