import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.nunitoTextTheme()),
      home: const TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with SingleTickerProviderStateMixin {
  List<String> board = List.filled(9, '');
  bool turnO = true;
  String winner = '';
  List<int> winningPattern = [];
  int moves = 0;

  String playerO = "Player O";
  String playerX = "Player X";

  int scoreO = 0;
  int scoreX = 0;
  int scoreDraw = 0;

  List<int> moveHistory = [];

  late ConfettiController _confettiController;

  final List<List<int>> winPatterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void handleTap(int index) {
    if (board[index] != '' || winner.isNotEmpty) return;

    setState(() {
      board[index] = turnO ? 'O' : 'X';
      moveHistory.add(index);
      turnO = !turnO;
      moves++;
      checkWinner();
    });
  }

  void undoMove() {
    if (moveHistory.isEmpty || winner.isNotEmpty) return;

    setState(() {
      int lastIndex = moveHistory.removeLast();
      board[lastIndex] = '';
      turnO = !turnO;
      moves--;
    });
  }

  void checkWinner() {
    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];
      if (a.isNotEmpty && a == b && b == c) {
        setState(() {
          winner = a;
          winningPattern = pattern;
          if (winner == 'O') {
            scoreO++;
          } else {
            scoreX++;
          }
          _confettiController.play();
        });
        return;
      }
    }

    if (moves == 9 && winner.isEmpty) {
      setState(() {
        winner = 'Draw';
        scoreDraw++;
      });
    }
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      turnO = true;
      winner = '';
      winningPattern = [];
      moves = 0;
      moveHistory.clear();
    });
  }

  void changePlayerNames() {
    TextEditingController oController = TextEditingController(text: playerO);
    TextEditingController xController = TextEditingController(text: playerX);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade50,
        title: const Text("Change Player Names"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oController,
              decoration: const InputDecoration(labelText: "Player O Name"),
            ),
            TextField(
              controller: xController,
              decoration: const InputDecoration(labelText: "Player X Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                playerO = oController.text;
                playerX = xController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Color getBoxColor(int index) {
    if (winningPattern.contains(index)) {
      return Colors.greenAccent.shade200;
    }
    return Colors.white.withOpacity(0.85);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Heading
                  Text(
                    "Tic Tac Toe",
                    style: GoogleFonts.lobsterTwo(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.purple.shade900,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Scoreboard
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$playerO: $scoreO   Draws: $scoreDraw   $playerX: $scoreX",
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  if (winner.isEmpty)
                    Text(
                      'Turn: ${turnO ? playerO : playerX}',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  if (winner.isNotEmpty)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        winner == 'Draw'
                            ? "It's a Draw!"
                            : "🎉 Winner: ${winner == 'O' ? playerO : playerX} 🎉",
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightGreenAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Game Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => handleTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: getBoxColor(index),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                board[index],
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: board[index] == 'O'
                                      ? Colors.deepPurple
                                      : Colors.pinkAccent.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Restart'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: undoMove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Undo'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: changePlayerNames,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade200,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Edit Names'),
                      ),
                    ],
                  ),
                ],
              ),

              // Confetti animation
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
