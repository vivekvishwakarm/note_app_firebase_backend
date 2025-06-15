import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/firestore_services.dart';


class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late final FireStoreServices _fireStoreService;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  File? _pickedImage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fireStoreService = FireStoreServices(uid:_currentUser!.uid);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _showNoteDialog({String? docId, String? existingTitle, String? existingContent,String? existingImageUrl}) {
    _titleController.text = existingTitle ?? '';
    _contentController.text = existingContent ?? '';
    _pickedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _contentController, decoration: const InputDecoration(labelText: "Content")),
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: ()  async{
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();

                String? imageUrl = existingImageUrl;

                // 🔥 Upload image if picked
                if (_pickedImage != null) {
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('user_notes')
                      .child(_currentUser!.uid)
                      .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

                  await storageRef.putFile(_pickedImage!);
                  imageUrl = await storageRef.getDownloadURL();
                }

                if (docId == null) {
                  await _fireStoreService.addNote(title, content, imageUrl);
                } else {
                  await _fireStoreService.updateNote(docId, title, content,imageUrl);
                }

                Navigator.pop(context);
              },
              child: Text(docId == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Optionally navigate to login screen here
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search notes...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 📄 Notes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fireStoreService.getNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final notes = snapshot.data!.docs;

                // 🔍 Local Filtering
                final filteredNotes = notes.where((note) {
                  final title = (note['title'] ?? '').toString().toLowerCase();
                  final content = (note['content'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery) || content.contains(_searchQuery);
                }).toList();

                if (filteredNotes.isEmpty) {
                  return const Center(child: Text("No matching notes found"));
                }

                return ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final noteId = note.id;
                    final title = note['title'];
                    final content = note['content'];
                    final imageUrl = note['imageUrl'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(title),
                        subtitle: Text(content),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showNoteDialog(
                                docId: noteId,
                                existingTitle: title,
                                existingContent: content,
                                existingImageUrl: imageUrl,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _fireStoreService.deleteNote(noteId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
