import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController _controller = TextEditingController();
  static const String _dataPath = 'example'; // Declare the path as a constant

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
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: _databaseRef.child(_dataPath).onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Center(child: Text('No data found'));
                  } else {
                    Map<dynamic, dynamic> data =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        String key = data.keys.elementAt(index);
                        String value = data[key]['data'];
                        return ListTile(
                          title: Text('Key: $key'),
                          subtitle: Text('Value: $value'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() async {
    try {
      // Generate a unique key for each new entry
      String? newKey = _databaseRef.child(_dataPath).push().key;

      // Use the unique key to add data under that key
      await _databaseRef
          .child(_dataPath)
          .child(newKey!)
          .set({'data': _controller.text});
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  void _retrieveData() async {
    try {
      DatabaseEvent event = await _databaseRef.child(_dataPath).once();
      print('Data retrieved: ${event.snapshot.value}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data retrieved: ${event.snapshot.value}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving data: $e')),
      );
    }
  }

  void _updateData() async {
    try {
      await _databaseRef
          .child(_dataPath)
          .update({'data': 'Updated ${_controller.text}'});
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating data: $e')),
      );
    }
  }

  void _deleteData() async {
    try {
      await _databaseRef.child(_dataPath).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting data: $e')),
      );
    }
  }
}
