import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HangmanGamePage(),
    );
  }
}

class HangmanGamePage extends StatefulWidget {
  const HangmanGamePage({Key? key}) : super(key: key);

  @override
  _HangmanGamePageState createState() => _HangmanGamePageState();
}

class _HangmanGamePageState extends State<HangmanGamePage> {
  final List<String> words = ['flutter', 'dart', 'hangman', 'game'];
  late String currentWord;
  late String displayedWord;
  int remainingAttempts = 10;
  bool isGameOver = false;
  TextEditingController wordController = TextEditingController();
  int incorrectAttempts = 0;
  List<HangmanGameResult> gameHistory = [];
  List<String> guessedLetters = [];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      currentWord = '';
      displayedWord = '';
      remainingAttempts = 10;
      isGameOver = false;
      incorrectAttempts = 0;
      guessedLetters.clear();
    });
  }

  void _checkLetter(String letter) {
    setState(() {
      if (!isGameOver && !guessedLetters.contains(letter)) {
        guessedLetters.add(letter);
        bool letterFound = false;
        String newDisplayedWord = '';
        for (int i = 0; i < currentWord.length; i++) {
          if (currentWord[i] == letter) {
            newDisplayedWord += letter;
            letterFound = true;
          } else {
            newDisplayedWord +=
                guessedLetters.contains(currentWord[i]) ? currentWord[i] : '_ ';
          }
        }
        displayedWord = newDisplayedWord;
        if (!letterFound) {
          remainingAttempts--;
          incorrectAttempts++;
          if (remainingAttempts == 0) {
            isGameOver = true;
            _endGame();
          }
        }
        if (displayedWord == currentWord) {
          isGameOver = true;
          _endGame();
        }
      }
    });
  }

  void _startGameWithCustomWord() {
    String word = wordController.text.trim().toLowerCase();
    if (word.isNotEmpty) {
      setState(() {
        currentWord = word;
        displayedWord = '_ ' * word.length;
        wordController.clear();
      });
    }
  }

  void _endGame() {
    if (isGameOver) {
      gameHistory.add(
        HangmanGameResult(
          word: currentWord,
          result: displayedWord == currentWord
              ? HangmanGameResultType.win
              : HangmanGameResultType.loss,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('😵 Hangman Game'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currentWord.isEmpty || isGameOver)
                if (gameHistory.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Game History',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Word')),
                            DataColumn(label: Text('Result')),
                          ],
                          rows: gameHistory.map((gameResult) {
                            return DataRow(
                              cells: [
                                DataCell(Text(gameResult.word)),
                                DataCell(
                                  Text(
                                    gameResult.result ==
                                            HangmanGameResultType.win
                                        ? 'Win'
                                        : 'Loss',
                                    style: TextStyle(
                                      color: gameResult.result ==
                                              HangmanGameResultType.win
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
              if (currentWord.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: wordController,
                        decoration: const InputDecoration(
                            labelText: 'Enter a word to guess'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical:
                                8.0), // Ajoute une marge verticale de 8.0 pixels autour du bouton
                        child: ElevatedButton(
                          onPressed: _startGameWithCustomWord,
                          child: const Text('Start Game'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (currentWord.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Nombre Essai: $remainingAttempts',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayedWord,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (isGameOver)
                      Text(
                        displayedWord == currentWord ? 'You won!' : 'You lost!',
                        style: TextStyle(
                            fontSize: 20,
                            color: displayedWord == currentWord
                                ? Colors.green
                                : Colors.red),
                      ),
                    if (!isGameOver)
                      Wrap(
                        spacing: 10,
                        children: List.generate(
                          26,
                          (index) {
                            final letter =
                                String.fromCharCode('a'.codeUnitAt(0) + index);
                            return GestureDetector(
                              onTap: () {
                                _checkLetter(letter);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: guessedLetters.contains(letter)
                                            ? Colors.transparent
                                            : const Color.fromARGB(
                                                255, 218, 218, 218),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        letter,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    if (guessedLetters.contains(letter))
                                      Icon(
                                        Icons.close,
                                        color: Color.fromARGB(255, 224, 83, 73),
                                        size: 28, // Taille de la croix
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (isGameOver)
                      ElevatedButton(
                        onPressed: () {
                          _startNewGame();
                        },
                        child: const Text('New Game'),
                      ),
                    const SizedBox(height: 20),
                    // Dessin du pendu
                    CustomPaint(
                      size: const Size(200, 200),
                      painter:
                          HangmanPainter(incorrectAttempts: incorrectAttempts),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int incorrectAttempts;

  HangmanPainter({required this.incorrectAttempts});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (incorrectAttempts > 0) {
      canvas.drawLine(
        Offset(size.width / 8, size.height / 6),
        Offset(3 * size.width / 4, size.height / 6),
        paint,
      );
    }

    // Ligne verticale
    if (incorrectAttempts > 1) {
      canvas.drawLine(
        Offset(size.width / 4,
            size.height / 6), // Début bien à gauche du premier trait
        Offset(size.width / 4, 6 * size.height / 6), // Fin à la hauteur totale
        paint,
      );
    }

    // Petite ligne diagonale
    if (incorrectAttempts > 2) {
      canvas.drawLine(
        Offset(
            1.5 * size.width / 4,
            size.height /
                6), // Début légèrement à droite du début de la première ligne horizontale
        Offset(size.width / 4, 2 * size.height / 5), // Fin au 3/4 de la hauteur
        paint,
      );
    }

    // Ligne verticale
    if (incorrectAttempts > 3) {
      canvas.drawLine(
        Offset(
            size.width / 2,
            size.height /
                6), // Début au milieu de la première ligne horizontale
        Offset(size.width / 2, size.height / 3), // Fin à un tiers de la hauteur
        paint,
      );
    }

    // Tête du pendu
    if (incorrectAttempts > 4) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 5 + 40), 15, paint);
    }

    // Corps
    if (incorrectAttempts > 5) {
      canvas.drawLine(
        Offset(size.width / 2, size.height / 5 + 50), // Début au niveau du cou
        Offset(size.width / 2, size.height / 3 + 80), // Fin un peu plus bas
        paint,
      );
    }

    if (incorrectAttempts > 6) {
      // Bras gauche
      canvas.drawLine(
        Offset(size.width / 2, size.height / 3 + 50),
        Offset(size.width / 2 - 30, size.height / 3 + 20),
        paint,
      );
    }

    if (incorrectAttempts > 7) {
      // Bras droit
      canvas.drawLine(
        Offset(
            size.width / 2, size.height / 3 + 50), // Début au niveau du corps
        Offset(size.width / 2 + 30,
            size.height / 3 + 20), // Fin un peu plus bas et vers la droite
        paint,
      );
    }

    // Jambe gauche
    if (incorrectAttempts > 8) {
      canvas.drawLine(
        Offset(
            size.width / 2, size.height / 3 + 80), // Début au niveau du corps
        Offset(size.width / 2 - 30,
            size.height * 2 / 2), // Fin un peu plus bas et vers la gauche
        paint,
      );
    }

    // Jambe droite
    if (incorrectAttempts > 9) {
      canvas.drawLine(
        Offset(
            size.width / 2, size.height / 3 + 80), // Début au niveau du corps
        Offset(size.width / 2 + 30,
            size.height * 2 / 2), // Fin un peu plus bas et vers la droite
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum HangmanGameResultType {
  win,
  loss,
}

class HangmanGameResult {
  final String word;
  final HangmanGameResultType result;

  HangmanGameResult({required this.word, required this.result});
}
