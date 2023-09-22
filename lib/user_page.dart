import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDate = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: controllerName,
            decoration: decoration('Name'),
          ),
          const SizedBox(
            height: 24,
          ),
          TextField(
            controller: controllerAge,
            decoration: decoration('Age'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(
            height: 24,
          ),
          // ToDo: Implement Date Picker
          TextField(
            controller: controllerDate,
            decoration: decoration('Birthday'),
            //format:
          ),
          const SizedBox(
            height: 32,
          ),
          ElevatedButton(
              onPressed: () {
                final user = User(
                  name: controllerName.text,
                  age: int.parse(controllerAge.text),
                  // DateFormat needs intl package
                  birthday: DateFormat("dd/MM/yyyy").parse(controllerDate.text),
                );
                createUser(user);
                Navigator.pop(context);
              },
              child: Text('Create'))
        ],
      ));

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      );

  Future createUser(User user) async {
    // Reference to document
    final docUser = FirebaseFirestore.instance
        .collection("users")
        .doc(); // Generate an automatic id
    final json = user.toJson();

    // Create document and write data to Firebase
    await docUser.set(json);

    /*final snackBar = SnackBar(
      content: Text('User ${user.name} created...'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
  }
}
