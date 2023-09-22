import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'user_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
        ),
        actions: [
          IconButton(
              onPressed: () {
                final name = controller.text;
                createUser(name: name);
              },
              icon: Icon(Icons.add))
        ],
      ),
      // StreamBuilder shows updates to the database online (it increases data consumption)
      // FutureBuilder doesn't show real time changes, just a snapshot
      body: //StreamBuilder(
          FutureBuilder(
        //stream: readUsers(), // Used with StreamBuilder
        future: readUsers().first, // Used with FutureBuilder
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
        leading: CircleAvatar(child: Text('${user.age}')),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
      );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

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
  }
}
