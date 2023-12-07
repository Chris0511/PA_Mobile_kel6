import 'package:aplikasi_kuis/ui/shared/color.dart';
import 'package:flutter/material.dart';
import 'hasilkuis_screen.dart';

class KuisScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedQuizzes;

  KuisScreen(this.selectedQuizzes);

  @override
  _KuisScreenState createState() => _KuisScreenState();
}

class _KuisScreenState extends State<KuisScreen> {
  int selectedOption = -1;
  int currentQuizIndex = 0;
  bool isAnswerSubmitted = false;
  int totalScore = 0;

  @override
  Widget build(BuildContext context) {
    final quizData = widget.selectedQuizzes[currentQuizIndex];
    final isLastQuestion =
        currentQuizIndex == widget.selectedQuizzes.length - 1;

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        title: Text('Kuis'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Kuis ${currentQuizIndex + 1}/${widget.selectedQuizzes.length}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.0),
                  Spacer(),
                  Text(
                    'Poin: $totalScore',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                '${quizData['pertanyaan']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Column(
                children: [
                  for (int i = 1; i <= 4; i++)
                    RadioListTile(
                      title: Text('$i: ${quizData['option$i'] as String}'),
                      value: i,
                      groupValue: selectedOption,
                      onChanged: isAnswerSubmitted
                          ? null
                          : (value) {
                              setState(() {
                                selectedOption = value as int;
                              });
                            },
                    ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (selectedOption != -1 && !isAnswerSubmitted) {
                        _checkAnswer(quizData['jawaban_benar'] as int, context);
                      }
                    },
                    child: Text('Jawab'),
                  ),
                  if (!isLastQuestion) Spacer(),
                  if (!isLastQuestion)
                    ElevatedButton(
                      onPressed: () {
                        if (isAnswerSubmitted) {
                          setState(() {
                            currentQuizIndex++;
                            selectedOption = -1;
                            isAnswerSubmitted = false;
                          });
                        }
                      },
                      child: Text('Next'),
                    ),
                  if (isLastQuestion && isAnswerSubmitted)
                    ElevatedButton(
                      onPressed: () {
                        _navigateToHasilKuisScreen(context);
                      },
                      child: Text('Lihat Hasil'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(int correctAnswer, BuildContext context) {
    if (selectedOption == correctAnswer) {
      _showAnswerNotification(context, 'Jawaban Benar! Poin +10', Colors.green);
      setState(() {
        totalScore += 10;
        widget.selectedQuizzes[currentQuizIndex]['user_answer'] =
            selectedOption;
      });
    } else {
      _showAnswerNotification(context, 'Jawaban Salah! Poin +0', Colors.red);
      widget.selectedQuizzes[currentQuizIndex]['user_answer'] = selectedOption;
    }

    setState(() {
      isAnswerSubmitted = true;
    });
  }

  void _navigateToHasilKuisScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HasilKuisScreen(
          questions: widget.selectedQuizzes,
          correctAnswersCount: _calculateCorrectAnswersCount(),
          incorrectAnswersCount: _calculateIncorrectAnswersCount(),
          totalScore: totalScore,
        ),
      ),
    );
  }

  int _calculateCorrectAnswersCount() {
    int correctCount = 0;
    for (var question in widget.selectedQuizzes) {
      final correctAnswer = question['jawaban_benar'] as int;
      final userAnswer = question['user_answer'] as int?;
      if (userAnswer != null && userAnswer == correctAnswer) {
        correctCount++;
      }
    }
    return correctCount;
  }

  int _calculateIncorrectAnswersCount() {
    return widget.selectedQuizzes.length - _calculateCorrectAnswersCount();
  }

  void _showAnswerNotification(
      BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
        backgroundColor: color,
      ),
    );
  }
}
