import 'package:aplikasi_kuis/screens/kuis_screen.dart';
import 'package:aplikasi_kuis/ui/shared/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PilihKuisScreen extends StatefulWidget {
  const PilihKuisScreen({Key? key}) : super(key: key);

  @override
  _PilihKuisScreenState createState() => _PilihKuisScreenState();
}

class _PilihKuisScreenState extends State<PilihKuisScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> quizzes = [];
  List<Map<String, dynamic>> filteredQuizzes = [];
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> selectedQuizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final QuerySnapshot categorySnapshot =
          await _firestore.collection('kuis').get();

      List<Map<String, dynamic>> retrievedQuizzes = [];

      for (QueryDocumentSnapshot categoryDocument in categorySnapshot.docs) {
        String categoryId = categoryDocument.id;

        final QuerySnapshot quizSnapshot = await _firestore
            .collection('kuis/$categoryId/Pertanyaan')
            .get();

        for (QueryDocumentSnapshot quizDocument in quizSnapshot.docs) {
          Map<String, dynamic> data =
              quizDocument.data() as Map<String, dynamic>;

          data['documentId'] = quizDocument.id;
          data['kategori'] = await getCategoryName(categoryId);

          retrievedQuizzes.add(data);
        }
      }

      setState(() {
        quizzes = retrievedQuizzes;
        filteredQuizzes = quizzes;
        isLoading = false; // Set isLoading to false when data is ready
      });
    } catch (error) {
      // Handle errors
      print('Error fetching quizzes: $error');
    }
  }

  Future<String> getCategoryName(String categoryId) async {
    final DocumentSnapshot categoryDoc =
        await _firestore.doc('kuis/$categoryId').get();
    if (categoryDoc.exists) {
      return categoryDoc.get('Kategori') ?? 'Kategori Tidak Diketahui';
    } else {
      return 'Kategori Tidak Diketahui';
    }
  }

  void _filterQuizzes(String query) {
    setState(() {
      filteredQuizzes = quizzes
          .where((quiz) =>
              quiz['pertanyaan']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              quiz['kategori'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  bool isQuizSelected(Map<String, dynamic> quiz) {
    return selectedQuizzes.contains(quiz);
  }

  void _onQuizTap(Map<String, dynamic> quizData) {
    setState(() {
      if (isQuizSelected(quizData)) {
        // batal pilih
        selectedQuizzes.remove(quizData);
      } else {
        // pilih kuis
        if (selectedQuizzes.length < 10) {
          selectedQuizzes.add(quizData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda hanya dapat memilih 10 kuis.'),
            ),
          );
        }
      }
    });
  }

  List<Map<String, dynamic>> _getRandomQuizzes() {
    List<Map<String, dynamic>> randomQuizzes = [];
    final List<Map<String, dynamic>> availableQuizzes =
        filteredQuizzes.isNotEmpty ? filteredQuizzes : quizzes;

    if (availableQuizzes.length <= 10) {
      randomQuizzes.addAll(availableQuizzes);
    } else {
      final List<Map<String, dynamic>> shuffledQuizzes =
          List<Map<String, dynamic>>.from(availableQuizzes)
            ..shuffle();
      randomQuizzes = shuffledQuizzes.sublist(0, 10);
    }

    return randomQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        title: Text('Pilih Kuis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedQuizzes = _getRandomQuizzes();
                });
              },
              child: Text('Pilih Acak'),
            ),
            SizedBox(height: 16),
            Text(
              'Pilih Kuis yang Ingin Dikerjakan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: _filterQuizzes,
              decoration: InputDecoration(
                labelText: 'Cari Kuis',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterQuizzes('');
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (filteredQuizzes.isNotEmpty)
              Expanded(
                child: ListView(
                  children: filteredQuizzes
                      .map(
                        (quizData) => Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isQuizSelected(quizData)
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(quizData['pertanyaan']),
                            subtitle:
                                Text('Kategori: ${quizData['kategori']}'),
                            onTap: () {
                              _onQuizTap(quizData);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
            else
              Center(
                child: Text('Belum ada kuis yang tersedia.'),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            if (selectedQuizzes.length >= 10) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KuisScreen(selectedQuizzes),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pilih 10 kuis untuk mulai.'),
                ),
              );
            }
          },
          child: Text('Mulai Kuis'),
        ),
      ],
    );
  }
}

class QuizSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> quizzes;

  QuizSearchDelegate(this.quizzes);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final List<Map<String, dynamic>> filteredList = quizzes
        .where((quiz) =>
            quiz['pertanyaan']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            quiz['kategori'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final quiz = filteredList[index];
        return ListTile(
          title: Text(quiz['pertanyaan']),
          subtitle: Text('Kategori: ${quiz['kategori']}'),
          onTap: () {
            close(context, quiz['pertanyaan']);
          },
        );
      },
    );
  }
}
