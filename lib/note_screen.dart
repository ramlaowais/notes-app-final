import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'note.dart';
import 'note_detail_screen.dart';

enum NoteSortOption {
  dateNewest,
  dateOldest,
  titleAsc,
  titleDesc,
}

class NoteScreen extends StatefulWidget {
  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  final _searchController = TextEditingController();
  NoteSortOption _currentSortOption = NoteSortOption.dateNewest;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
    _searchController.addListener(_filterNotes);
  }

  void _refreshNotes() async {
    final notes = await DBHelper().getNotes();
    setState(() {
      _notes = notes;
      _sortNotes(); // Apply sorting after fetching notes
      _filterNotes(); // Apply filter after sorting
    });
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query) || note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _sortNotes() {
    switch (_currentSortOption) {
      case NoteSortOption.dateNewest:
        _notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case NoteSortOption.dateOldest:
        _notes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case NoteSortOption.titleAsc:
        _notes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case NoteSortOption.titleDesc:
        _notes.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyNotes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 8,
        shadowColor: Colors.deepPurple.shade900,
        actions: [
          PopupMenuButton<NoteSortOption>(
            onSelected: (NoteSortOption result) {
              setState(() {
                _currentSortOption = result;
                _sortNotes();
                _filterNotes(); // Re-filter after sorting, to update the displayed list
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<NoteSortOption>>[
              PopupMenuItem<NoteSortOption>(
                value: NoteSortOption.dateNewest,
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Date (Newest First)'),
                  ],
                ),
              ),
              PopupMenuItem<NoteSortOption>(
                value: NoteSortOption.dateOldest,
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Date (Oldest First)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<NoteSortOption>(
                value: NoteSortOption.titleAsc,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Title (A-Z)'),
                  ],
                ),
              ),
              PopupMenuItem<NoteSortOption>(
                value: NoteSortOption.titleDesc,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Title (Z-A)'),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.sort, color: Colors.white, size: 28),
            tooltip: 'Sort notes',
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                filled: true,
                fillColor: Colors.deepPurple.shade50,
              ),
              cursorColor: Colors.deepPurple,
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notes, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 10),
                        Text(
                          'No notes yet! Tap the + button to add one.',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                          leading: Icon(Icons.note_alt, color: Colors.deepPurple.shade400, size: 30),
                          title: Text(
                            note.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple.shade800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6),
                              Text(
                                note.content.split('\n').take(2).join(' '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  note.timestamp.substring(0, 16),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: false,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
                            );
                            _refreshNotes();
                          },
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailScreen()),
          );
          _refreshNotes();
        },
        child: Icon(Icons.add, color: Colors.white, size: 30),
        backgroundColor: Colors.deepPurple.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        tooltip: 'Add New Note',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}