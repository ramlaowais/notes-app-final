import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'note.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  NoteDetailScreen({this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final timestamp = DateTime.now().toString().substring(0, 19); // Format timestamp to YYYY-MM-DD HH:MM:SS

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Title cannot be empty!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    if (widget.note == null) {
      await DBHelper().insertNote(Note(title: title, content: content, timestamp: timestamp));
    } else {
      await DBHelper().updateNote(
        Note(id: widget.note!.id, title: title, content: content, timestamp: timestamp),
      );
    }
    Navigator.pop(context);
  }

  void _deleteNote() async {
    if (widget.note != null) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text('Delete Note', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('Are you sure you want to delete this note permanently? This action cannot be undone.'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.deepPurple, fontSize: 16)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete_forever, color: Colors.white),
                label: Text('Delete', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await DBHelper().deleteNote(widget.note!.id!);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Create New Note' : 'Edit Note',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 8,
        shadowColor: Colors.deepPurple.shade900,
        actions: [
          if (widget.note != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 28),
              onPressed: _deleteNote,
              tooltip: 'Delete Note',
            )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note Title',
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.deepPurple.shade600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.deepPurple.shade50,
                prefixIcon: Icon(Icons.title, color: Colors.deepPurple.shade400),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.deepPurple.shade900),
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Colors.deepPurple,
            ),
            SizedBox(height: 18),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Write your note content here...',
                  labelText: 'Content',
                  labelStyle: TextStyle(color: Colors.deepPurple.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.deepPurple.shade50,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 100), // Adjust icon position for multiline
                    child: Icon(Icons.description, color: Colors.deepPurple.shade400),
                  ),
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
                style: TextStyle(fontSize: 16, color: Colors.deepPurple.shade800),
                keyboardType: TextInputType.multiline,
                cursorColor: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 25),
            Container(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save, color: Colors.white, size: 24),
                label: Text(
                  widget.note == null ? 'Save New Note' : 'Update Note',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: Colors.deepPurple.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}