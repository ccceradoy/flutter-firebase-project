import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // get the current user
  Stream<User?> getUser() {
    return auth.authStateChanges();
  }

  // will get the data of the current user after logging in, in a form of Map
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      late Map<String, dynamic> x;
      final docRef = db.collection('users').doc(auth.currentUser!.uid);
      await docRef.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          // manually add the id coz its not included in the .get
          data['id'] = auth.currentUser!.uid;
          x = data;
        },
        onError: (e) => print("Error getting document: $e"),
      );
      return x;
    } on FirebaseException catch (e) {}
  }

  // get all the users that sends a friend request tot the current user
  Stream<QuerySnapshot> getReceivedRequests() {
    return db
        .collection('users')
        .where('sentRequest', arrayContains: auth.currentUser!.uid)
        .snapshots();
  }

  // get all friends of either the current user, or the id of the visited profile's user
  Stream<QuerySnapshot> getFriends(String id) {
    return db
        .collection('users')
        .where('friends', arrayContains: id)
        .snapshots();
  }

  // get all user that the current user is either not friend with, did not send request,
  // or did not receive request
  Stream<QuerySnapshot> getNotFriends(
      String userId, List userFriends, List receive, List sent) {
    return db.collection('users').where('id',
        whereNotIn: [userId, ...userFriends, ...receive, ...sent]).snapshots();
  }

  // when signin up, there is no bio field
  // user can add a bio
  Future<String> addBio(String bio) async {
    try {
      final docRef = db.collection('users').doc(auth.currentUser!.uid);
      await docRef.update({'bio': bio});
      return "Bio added";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  // add friend based on the String id
  Future<String> addFriend(String id) async {
    try {
      // current user
      final docRef = db.collection('users').doc(auth.currentUser!.uid);
      docRef.get().then(
        (DocumentSnapshot doc) {
          // current user data
          final data = doc.data() as Map<String, dynamic>;

          // also get the user to be added
          final userToAddRef = db.collection('users').doc(id);
          userToAddRef.get().then((DocumentSnapshot doc) async {
            final userToAddRefData = doc.data() as Map<String, dynamic>;

            if (!data['sentRequest'].contains(id)) {
              await db.collection('users').doc(auth.currentUser!.uid).update({
                'sentRequest': [...data['sentRequest'], id]
              });
              await userToAddRef.update({
                'receivedRequest': [
                  ...userToAddRefData['receivedRequest'],
                  data['id'],
                ]
              });

              // notify the added user
              userToAddRefData['notification'].add(
                  '${data['firstName']} ${data['lastName']} sent you a friend request @ ${DateFormat('yyyy-MM-dd').format(DateTime.now())}, ${DateFormat.jm().format(DateTime.now())}');

              // max notification is 10
              if (userToAddRefData['notification'].length > 10) {
                userToAddRefData['notification'].removeAt(0);
              }

              await userToAddRef
                  .update({'notification': userToAddRefData['notification']});
            }
          });
        },
        onError: (e) => print("Error getting document: $e"),
      );
      return "User added";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  // a user can also unfriend a user
  Future<String> removeFriend(String id) async {
    try {
      final docRef = db.collection('users').doc(auth.currentUser!.uid);
      docRef.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          // remove the user from the friends array
          data['friends'].remove(id);

          // also get the user to be removed
          final userToRemoveRef = db.collection('users').doc(id);
          userToRemoveRef.get().then((DocumentSnapshot doc) async {
            final userToRemoveRefData = doc.data() as Map<String, dynamic>;
            userToRemoveRefData['friends'].remove(auth.currentUser!.uid);

            // update their fields
            await docRef.update({
              'friends': [...data['friends']]
            });
            await userToRemoveRef.update({
              'friends': [...userToRemoveRefData['friends']]
            });
          });
        },
        onError: (e) => print("Error getting document: $e"),
      );
      return "User removed from the friendlist";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  // accept a user based on the String id
  Future<String> acceptFriend(String id) async {
    try {
      final docRef = db.collection('users').doc(auth.currentUser!.uid);
      docRef.get().then(
        (DocumentSnapshot doc) async {
          final data = doc.data() as Map<String, dynamic>;

          // also get the user to be accepted
          final userToAcceptRef = db.collection('users').doc(id);
          await userToAcceptRef.get().then((DocumentSnapshot doc) async {
            final userToAcceptData = doc.data() as Map<String, dynamic>;

            if (data['receivedRequest'].contains(id) &&
                !data['friends'].contains(id)) {
              await db.collection('users').doc(auth.currentUser!.uid).update({
                'friends': [...data['friends'], id]
              });

              data['receivedRequest'].remove(userToAcceptData['id']);
              await db.collection('users').doc(auth.currentUser!.uid).update({
                'receivedRequest': [...data['receivedRequest']]
              });

              await userToAcceptRef.update({
                'friends': [
                  ...userToAcceptData['friends'],
                  data['id'],
                ]
              });

              userToAcceptData['sentRequest'].remove(data['id']);
              await db.collection('users').doc(userToAcceptData['id']).update({
                'sentRequest': [...userToAcceptData['sentRequest']]
              });

              userToAcceptData['notification'].add(
                  '${data['firstName']} ${data['lastName']} accepted your friend request@ ${DateFormat('yyyy-MM-dd').format(DateTime.now())}, ${DateFormat.jm().format(DateTime.now())}');
              // the array should only have 10 max notifs
              if (userToAcceptData['notification'].length > 10) {
                userToAcceptData['notification'].removeAt(0);
              }

              await userToAcceptRef
                  .update({'notification': userToAcceptData['notification']});
            }
          });
        },
        onError: (e) => print("Error getting document: $e"),
      );
      return "User accepted";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String?> logIn(email, password) async {
    UserCredential credential;
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
  }

  void logOut() {
    auth.signOut();
  }

  Future<String?> signUp({
    id,
    firstName,
    lastName,
    username,
    email,
    password,
    birthday,
    location,
    notification,
  }) async {
    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        saveUserToFireStore(
          credential.user?.uid,
          firstName,
          lastName,
          username,
          email,
          password,
          birthday,
          location,
          notification,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Email already exists";
      }
    } catch (e) {
      print(e);
    }
  }

  void saveUserToFireStore(uid, firstName, lastName, username, email, password,
      birthday, location, notification) async {
    try {
      await db.collection('users').doc(uid).set({
        'id': uid,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'birthday': birthday,
        'location': location,
        'friends': [],
        'sentRequest': [],
        'receivedRequest': [],
        'bio': '',
        'todos': [],
        'notification': [],
      });
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
}
