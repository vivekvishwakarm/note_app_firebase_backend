import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreServices {
  // FireStore instance
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  // User ID
  final String? uid;

  // Collection references
  FireStoreServices({this.uid});

  // add note
  Future<void> addNote(String title, String content,String? imageUrl) async {
    try {
      await _fireStore.collection("users").doc(uid).collection("notes").add({
        "title": title,
        "content": content,
        "imageUrl": imageUrl,
        "timestamp": Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error adding note: $e");
      }
    }
  }

  // Get note stream
  Stream<QuerySnapshot> getNotes() {
    return _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // Update Note
  Future<void> updateNote(String noteId, String title, String content,String? imageUrl) async {
    await _fireStore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .update({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete Note
  // Delete Note with optional image deletion
  Future<void> deleteNote(String noteId) async {
    final noteRef = _fireStore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId);

    // 🔍 Step 1: Get the note document
    final noteSnapshot = await noteRef.get();

    // 🔍 Step 2: Extract imageUrl if exists
    final imageUrl = noteSnapshot.data()?['imageUrl'];

    // 🗑️ Step 3: If imageUrl is not null, delete it from storage
    if (imageUrl != null) {
      try {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
        print('✅ Image deleted from Firebase Storage');
      } catch (e) {
        print('❌ Failed to delete image: $e');
      }
    }

    // 🧹 Step 4: Delete the note document from Firestore
    await noteRef.delete();
    print('✅ Note deleted from Firestore');
  }



}
