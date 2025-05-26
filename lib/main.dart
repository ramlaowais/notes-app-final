import 'package:flutter/material.dart';
import 'note_screen.dart';

void main() {
  runApp(MyNotesApp());
}

class MyNotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyNotes',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: NoteScreen(),
    );
  }
}
