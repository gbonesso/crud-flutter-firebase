import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';

class UpdateUserPage extends StatefulWidget {
  final User? user;

  const UpdateUserPage({super.key, this.user});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  late final controllerName;
  late final controllerAge;
  late final controllerDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final dateFormat = DateFormat('dd/MM/yyyy');
    controllerName = TextEditingController(text: widget.user!.name);
    controllerAge = TextEditingController(text: widget.user!.age.toString());
    controllerDate =
        TextEditingController(text: dateFormat.format(widget.user!.birthday));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Update User'),
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
                updateUser();
                Navigator.pop(context);
              },
              child: Text('Update'))
        ],
      ));

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      );

  Future updateUser() async {
    final updateUser = User(
      id: widget.user!.id,
      name: controllerName.text,
      age: int.parse(controllerAge.text),
      // DateFormat needs intl package
      birthday: DateFormat("dd/MM/yyyy").parse(controllerDate.text),
    );

    print('updateUser: ${updateUser.toJson()}');
    // Reference to document
    final docUser = FirebaseFirestore.instance
        .collection("users")
        .doc(updateUser.id); // Selects the user ID for update

    final json = updateUser.toJson();
    docUser.update(json);
  }
}
