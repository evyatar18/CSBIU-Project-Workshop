import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final firestore = Firestore.instance;
  final root = firestore.collection('version').document('1');
  Flamingo.configure(
      firestore: firestore, storage: FirebaseStorage.instance, root: root);

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Digitalization',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.redAccent
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hello world"),
        ),

        body: Center(
          child: FloatingActionButton(onPressed: () => print("pressed"), child: Icon(Icons.add))
        )
      ),
    );
  }
}
