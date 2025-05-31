import 'package:flutter/material.dart';
import 'package:note_app_salsabila/helper/db_helper.dart';
import 'package:note_app_salsabila/model/model_note.dart';
import 'package:note_app_salsabila/screen/note_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  List<Note> _selectedNotes = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _selectMode = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = _searchQuery.isEmpty
        ? await DBHelper().getNotes()
        : await DBHelper().searchNotes(_searchQuery);
    setState(() {
      _notes = notes;
      _isLoading = false;
      _selectedNotes.clear();
      _selectMode = false;
    });
  }

  void _navigateToForm([Note? note]) async {
    if (_selectMode) {
      _toggleSelect(note!);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
      );
      _loadNotes();
    }
  }

  void _toggleSelect(Note note) {
    setState(() {
      if (_selectedNotes.contains(note)) {
        _selectedNotes.remove(note);
        if (_selectedNotes.isEmpty) _selectMode = false;
      } else {
        _selectedNotes.add(note);
        _selectMode = true;
      }
    });
  }

  void _deleteSelectedNotes() async {
    for (var note in _selectedNotes) {
      await DBHelper().deleteNote(note.id!);
    }
    _loadNotes();
  }

  void _deleteNoteConfirm(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.pink[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Note', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[900])),
        content: Text('Are you sure you want to delete this note?', style: TextStyle(color: Colors.pink[800])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.pink[700]))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote(id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int id) async {
    await DBHelper().deleteNote(id);
    _loadNotes();
  }

  void _togglePin(Note note) async {
    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      isPinned: !note.isPinned,
    );
    await DBHelper().updateNote(updatedNote);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelecting = _selectMode;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.pink[800],
          elevation: 0,
          leading: isSelecting
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedNotes.clear();
                _selectMode = false;
              });
            },
          )
              : null,
          title: Text(
            isSelecting
                ? '${_selectedNotes.length} selected'
                : 'My Notes',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          actions: isSelecting
              ? [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _selectedNotes.isEmpty ? null : _deleteSelectedNotes,
            ),
          ]
              : [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.pink[900],
                backgroundImage: AssetImage('gambar/salsaa.jpg'),
              ),
            ),
          ],
          bottom: isSelecting
              ? null
              : PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _loadNotes();
                  },
                  style: const TextStyle(fontSize: 15, color: Colors.pinkAccent),
                  cursorColor: Colors.pink[800],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.pink[600]),
                    hintText: 'Search ',
                    hintStyle: TextStyle(color: Colors.pink[300]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.pink))
            : _notes.isEmpty
            ? Center(
          child: Text(
            'Tulis',
            style: TextStyle(color: Colors.pink[300], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: GridView.builder(
            itemCount: _notes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5 / 3,
            ),
            itemBuilder: (context, index) {
              final note = _notes[index];
              final isSelected = _selectedNotes.contains(note);

              return GestureDetector(
                onLongPress: () => _toggleSelect(note),
                child: Stack(
                  children: [
                    Material(
                      color: isSelected ? Colors.pink[100] : Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _navigateToForm(note),
                        splashColor: Colors.pink.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _togglePin(note),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                        color: note.isPinned ? Colors.pink[700] : Colors.pink[300],
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  if (!_selectMode)
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _deleteNoteConfirm(note.id!),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.pink[300],
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                note.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.pink[900],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  note.content,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.pink[700],
                                    height: 1.3,
                                  ),
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  DateTime.now().toString().split(' ')[0],
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.pink[300],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_selectMode)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 12,
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.pink : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      floatingActionButton: !_selectMode
          ? Padding(
        padding: const EdgeInsets.only(bottom: 14, right: 14),
        child: FloatingActionButton(
          onPressed: () => _navigateToForm(),
          backgroundColor: Colors.pink[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, size: 32),
          elevation: 6,
          tooltip: 'Add new note',
        ),
      )
          : null,
    );
  }
}
