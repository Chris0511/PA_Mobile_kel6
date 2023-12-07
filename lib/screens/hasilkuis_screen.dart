import 'package:flutter/material.dart';

import 'home.dart';

class HasilKuisScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final int correctAnswersCount;
  final int incorrectAnswersCount;
  final int totalScore;

  HasilKuisScreen({
    required this.questions,
    required this.correctAnswersCount,
    required this.incorrectAnswersCount,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Kuis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jawaban Benar: $correctAnswersCount'),
            Text('Jawaban Salah: $incorrectAnswersCount'),
            Text('Total Poin: $totalScore'),
            SizedBox(height: 16.0),
            Text('Detail Pertanyaan dan Jawaban:'),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final questionText = question['pertanyaan'] as String;
                  final correctAnswer = question['jawaban_benar'] as int;
                  final userAnswer = question['user_answer'] as int?;
                  final options = List.generate(
                      4, (i) => question['option${i + 1}'] as String);

                  return ListTile(
                    title: Text(questionText),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilihan 1: ${options[0]}'),
                        Text('Pilihan 2: ${options[1]}'),
                        Text('Pilihan 3: ${options[2]}'),
                        Text('Pilihan 4: ${options[3]}'),
                        Text('Jawaban Benar: Pilihan $correctAnswer'),
                        if (userAnswer != null)
                          Text('Jawaban Anda: Pilihan $userAnswer'),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            // Home button
            ElevatedButton(
              onPressed: () {              
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              child: Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}
