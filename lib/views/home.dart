// home.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter some data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save to Database'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retrieveData,
              child: Text('Retrieve from Database'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateData,
              child: Text('Update Database'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteData,
              child: Text('Delete from Database'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() {
    _databaseRef.child('example').set({'data': _controller.text});
    _controller.clear();
  }

  void _retrieveData() {
    _databaseRef.child('example').once().then((DatabaseEvent event) {
      print('Data retrieved: ${event.snapshot.value}');
    });
  }

  void _updateData() {
    _databaseRef
        .child('example')
        .update({'data': 'Updated ${_controller.text}'});
    _controller.clear();
  }

  void _deleteData() {
    _databaseRef.child('example').remove();
  }
}
