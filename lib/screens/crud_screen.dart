import 'package:aplikasi_kuis/ui/shared/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../function/hapus_kuis.dart';

void main() {
  runApp(MaterialApp(
    home: CrudScreen(),
  ));
}

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedCategoryId = 'Uhpj08fp7UQQiN67V6SZ';
  TextEditingController pertanyaanController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  int? selectedAnswer;

  List<Map<String, dynamic>> categories = [];
  List<String> kuisOptions = [];
  List<Map<String, dynamic>> quizzes = [];
  bool isEditMode = false;
  String? selectedQuizDocumentId;

  Future<void> _readQuizzes() async {
    String kategoriId = selectedCategoryId ?? '';

    final QuerySnapshot snapshot =
        await _firestore.collection('kuis/$kategoriId/Pertanyaan').get();

    List<Map<String, dynamic>> retrievedQuizzes = [];

    for (QueryDocumentSnapshot document in snapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      data['documentId'] = document.id;
      retrievedQuizzes.add(data);
    }

    setState(() {
      quizzes = retrievedQuizzes;
    });
  }

  void tambahKuis() async {
    String kategoriId = selectedCategoryId ?? '';

    try {
      if (isEditMode) {
        await _firestore
            .collection('kuis/$kategoriId/Pertanyaan')
            .doc(selectedQuizDocumentId)
            .update({
          'pertanyaan': pertanyaanController.text,
          'option1': option1Controller.text,
          'option2': option2Controller.text,
          'option3': option3Controller.text,
          'option4': option4Controller.text,
          'jawaban_benar': selectedAnswer,
        });

        setState(() {
          isEditMode = false;
          selectedQuizDocumentId = null;
        });
      } else {
        DocumentReference documentReference =
            await _firestore.collection('kuis/$kategoriId/Pertanyaan').add({
          'pertanyaan': pertanyaanController.text,
          'option1': option1Controller.text,
          'option2': option2Controller.text,
          'option3': option3Controller.text,
          'option4': option4Controller.text,
          'jawaban_benar': selectedAnswer,
        });

        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map<String, dynamic> newQuizData =
            documentSnapshot.data() as Map<String, dynamic>;
        newQuizData['documentId'] = documentSnapshot.id;

        setState(() {
          quizzes.add(newQuizData);
        });
      }

      // Refresh the quizzes data after a successful update or addition
      await _readQuizzes();

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Berhasil simpan kuis.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });

      pertanyaanController.clear();
      option1Controller.clear();
      option2Controller.clear();
      option3Controller.clear();
      option4Controller.clear();
      selectedAnswer = null;
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Isi semua data kuis!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _readQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        title: Text('Buat Kuis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Kategori',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedCategoryId,
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value;
                          _readQuizzes();
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Uhpj08fp7UQQiN67V6SZ',
                          child: Text('Sejarah Indonesia'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'FwfVj0o4YB2YkTR0djjQ',
                          child: Text('Sejarah Dunia'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'cFSzqFVINFn0XXj22Q7W',
                          child: Text('Olahraga'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'rk4h22NQnYakIGuhnC4P',
                          child: Text('Teknologi'),
                        ),
                        DropdownMenuItem<String>(
                          value: '9riry1dGZgBtNXoRCKBP',
                          child: Text('Seni Budaya'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Input Kuis',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: kuisOptions
                          .map(
                            (option) => RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: selectedCategoryId,
                              onChanged: (value) {
                                setState(() {
                                  selectedCategoryId = value;
                                  _readQuizzes();
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          TextFormField(
                            controller: pertanyaanController,
                            decoration: InputDecoration(
                              labelText: 'Pertanyaan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: option1Controller,
                            decoration: InputDecoration(
                              labelText: 'Pilihan 1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: option2Controller,
                            decoration: InputDecoration(
                              labelText: 'Pilihan 2',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: option3Controller,
                            decoration: InputDecoration(
                              labelText: 'Pilihan 3',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: option4Controller,
                            decoration: InputDecoration(
                              labelText: 'Pilihan 4',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: selectedAnswer,
                            onChanged: (value) {
                              setState(() {
                                selectedAnswer = value;
                              });
                            },
                            items: [1, 2, 3, 4].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('Pilihan $value'),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Jawaban Benar (pilihan ke-)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              tambahKuis();
                            },
                            child: Text('Simpan Kuis'),
                          ),
                          SizedBox(height: 16),
                          if (quizzes.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Semua Kuis:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  for (Map<String, dynamic> quizData in quizzes)
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      margin: EdgeInsets.only(bottom: 8.0),
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Pertanyaan: ${quizData['pertanyaan']}\n'
                                              'Indeks 0: ${quizData['option1']}\n'
                                              'Indeks 1: ${quizData['option2']}\n'
                                              'Indeks 2: ${quizData['option3']}\n'
                                              'Indeks 3: ${quizData['option4']}\n'
                                              'Jawaban(indeks): ${quizData['jawaban_benar']}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  setState(() {
                                                    isEditMode = true;
                                                    selectedQuizDocumentId =
                                                        quizData['documentId'];
                                                    pertanyaanController.text =
                                                        quizData['pertanyaan'];
                                                    option1Controller.text =
                                                        quizData['option1'];
                                                    option2Controller.text =
                                                        quizData['option2'];
                                                    option3Controller.text =
                                                        quizData['option3'];
                                                    option4Controller.text =
                                                        quizData['option4'];
                                                    selectedAnswer = quizData[
                                                        'jawaban_benar'];
                                                  });
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () {
                                                  hapusKuis(
                                                      context,
                                                      quizData['documentId'],
                                                      selectedCategoryId!,
                                                      quizzes,
                                                      (updatedQuizzes) {
                                                    setState(() {
                                                      quizzes = updatedQuizzes;
                                                    });
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
