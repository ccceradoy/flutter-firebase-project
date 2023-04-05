import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/api/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  User? userObj;

  AuthProvider() {
    authService = FirebaseAuthAPI();
    authService.getUser().listen((User? newUser) {
      userObj = newUser;
      notifyListeners();
    }, onError: (e) {});
  }

  User? get user => userObj;

  changeUser(User user) {
    userObj = user;
  }

  bool get isAuthenticated {
    return user != null;
  }

  // stream for all the user that is friends with the current user
  Stream<QuerySnapshot> friends(String id) {
    return authService.getFriends(id);
  }

  // stream for all the user that is not friends with the current user
  Stream<QuerySnapshot> notFriends(
      String userId, List userFriends, List receive, List sent) {
    return authService.getNotFriends(userId, userFriends, receive, sent);
  }

  // stream for all the user that added the current user
  Stream<QuerySnapshot> get receivedRequests =>
      authService.getReceivedRequests();

  // the user data in the form of Map
  Future<Map<String, dynamic>?> get userJson => authService.getUserData();

  // call the addBio from the provider
  void addBio(String bio) async {
    String x = await authService.addBio(bio);
    print(x);
    notifyListeners();
  }

  Future<String> addFriend(String userUid) {
    return authService.addFriend(userUid);
  }

  Future<String> removeFriend(String id) {
    return authService.removeFriend(id);
  }

  Future<String> acceptFriend(String userUid) {
    return authService.acceptFriend(userUid);
  }

  Future<String?> logIn(email, password) {
    return authService.logIn(email, password);
  }

  void logOut() {
    authService.logOut();
  }

  Future<String?> signUp(
      {id,
      firstName,
      lastName,
      username,
      email,
      password,
      birthday,
      location,
      notification}) {
    return authService.signUp(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
      birthday: birthday,
      location: location,
      notification: notification,
    );
  }
}
