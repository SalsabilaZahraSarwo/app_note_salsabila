import 'package:flutter/material.dart';
import 'package:note_app_salsabila/helper/db_helper.dart';
import 'package:note_app_salsabila/model/model_note.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  final Color _primaryPink = const Color(0xFFE91E63);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isPinned: widget.note?.isPinned ?? false,
    );

    if (widget.note == null) {
      await DBHelper().insertNote(note);
    } else {
      await DBHelper().updateNote(note);
    }

    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: _primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter your note title',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      suffixIcon: Icon(Icons.title, color: _primaryPink.withOpacity(0.7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 6,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      hintText: 'Write your note here...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0), // adjust icon position
                        child: Icon(Icons.notes, color: _primaryPink.withOpacity(0.7)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter some content' : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveNote,
                      icon: _isSaving
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Save',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
