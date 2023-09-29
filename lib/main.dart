// https://www.youtube.com/watch?v=ErP_xomHKTw
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'user_page.dart';
import 'update_user_page.dart';
import 'user.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Before initializing Firebase WidgetsFlutterBinding must be initialized.
  // It provides comunication between flutter and native code for Firebase
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final controller = TextEditingController();
  late List<User> _userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userData = readUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Test'),
        /*TextField(
          controller: controller,
        ),*/
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _userData = readUsers();
                });
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      // StreamBuilder shows updates to the database online (it increases data consumption)
      // FutureBuilder doesn't show real time changes, just a snapshot
      body: StreamBuilder(
        //FutureBuilder(
        // This is FutureBuilder for all users
        stream: readUsersStream(), // Used with StreamBuilder
        //future: _userData, // Used with FutureBuilder
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView(children: users.map(buildUser).toList());
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      /*FutureBuilder<User?>(
        // This is FutureBuilder for one user
        future: readUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final user = snapshot.data;
            return user == null
                ? Center(child: Text('No User'))
                : buildUser(user);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),*/
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserPage()),
          );
        },
      ),
    );
  }

  Widget buildUser(User user) => ListTile(
        leading: IconButton(
            onPressed: () {
              // Update User
              print('Teste: ${user.toJson()} ${user.id}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateUserPage(
                    user: user,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit)),
        title: Text('${user.name} - Age: ${user.age}'),
        subtitle: Text(user.birthday.toIso8601String()),
        trailing: IconButton(
          onPressed: () {
            _deleteUser(user.id);
          },
          icon: const Icon(Icons.delete),
        ),
      );

  void _deleteUser(final userID) {
    print('userID: $userID');
    final docUser = FirebaseFirestore.instance.collection('users').doc(userID);
    docUser.delete();
    setState(() {
      _userData = readUsers();
    });
  }

  Future<User?> readUser(final userID) async {
    // Get single document by ID
    final docUser = FirebaseFirestore.instance.collection('users').doc(userID);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
  }

  // Read all users for use with FutureBuilder or StreamBuilder
  Stream<List<User>> readUsersStream() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  List<User> readUsers() {
    List<User> userList = [];

    FirebaseFirestore.instance.collection("cities").get().then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    return userList;
  }

  Future createUser({required String name}) async {
    print("createUser: $name");
    // Reference to document
    final docUser = FirebaseFirestore.instance
        .collection("users")
        .doc(); // Generate an automatic id
    /*final json = {
      "name": name,
      "age": 21,
      "birthday": DateTime(2001, 7, 28),
    };*/
    final user = User(
      id: docUser.id,
      name: name,
      age: 50,
      birthday: DateTime(1973, 6, 13),
    );
    final json = user.toJson();

    // Create document and write data to Firebase
    await docUser.set(json);
    //setState(() {});
  }
}
