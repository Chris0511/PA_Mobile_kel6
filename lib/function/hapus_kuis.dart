import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> hapusKuis(BuildContext context, String quizDocumentId, String kategoriId, List<Map<String, dynamic>> quizzes, Function(List<Map<String, dynamic>>) updateQuizzes) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Show a confirmation dialog
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Anda yakin menghapus kuis ini?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // If "Iya" is pressed, return true
              Navigator.of(context).pop(true);
            },
            child: Text('Iya'),
          ),
          TextButton(
            onPressed: () {
              // If "Tidak" is pressed, return false
              Navigator.of(context).pop(false);
            },
            child: Text('Tidak'),
          ),
        ],
      );
    },
  );

  // If the user confirms the delete, proceed with deletion
  if (confirmDelete == true) {
    try {
      // Delete the quiz based on the provided document ID
      await _firestore
          .collection('kuis/$kategoriId/Pertanyaan')
          .doc(quizDocumentId)
          .delete();

      print('Kuis berhasil dihapus');

      // Update the local state to reflect the deleted quiz
      List<Map<String, dynamic>> updatedQuizzes = List.from(quizzes);
      updatedQuizzes.removeWhere((quiz) => quiz['documentId'] == quizDocumentId);
      updateQuizzes(updatedQuizzes); // Call the provided function to update state
    } catch (error) {
      print('Error saat menghapus kuis: $error');
      // You can handle the error accordingly, e.g., show another dialog
    }
  }
}
