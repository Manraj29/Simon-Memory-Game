import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(SimonGameApp());
  });
}

class SimonGameApp extends StatefulWidget {
  const SimonGameApp({super.key});

  @override
  State<SimonGameApp> createState() => _SimonGameAppState();
}

class _SimonGameAppState extends State<SimonGameApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simon Game',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: SimonGameScreen(changeTheme: changeTheme),
    );
  }

  void changeTheme() {
    setState(() {
      themeMode =
          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }
}

class SimonGameScreen extends StatefulWidget {
  const SimonGameScreen({super.key, required this.changeTheme});

  final Function changeTheme;

  @override
  State<SimonGameScreen> createState() => _SimonGameScreenState();
}

class _SimonGameScreenState extends State<SimonGameScreen> {
  int round = 1;
  bool isPlayerTurn = false;
  List<String> colorSequence = [];
  List<String> userInput = [];

  bool isPlaying = false;
  // This list holds the flash state for each of the buttons (whether they should be white or their color)
  List<Color> colorFlashState = [
    Colors.white, // Red
    Colors.white, // Green
    Colors.white, // Blue
    Colors.white, // Yellow
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simon Game',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Round: $round',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              isPlaying
                  ? !isPlayerTurn
                      ? 'Watch the sequence'
                      : '${colorSequence.length} Colors in sequence'
                  : 'Press Start to play',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: [
                colorButton('Red', Colors.red, 0),
                colorButton('Green', Colors.green, 1),
                colorButton('Blue', Colors.blue, 2),
                colorButton('Yellow', Colors.yellow, 3),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // print('Start Game');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Instructions'),
                      content: Text(
                          'Watch the sequence of colors and repeat it back by tapping the colors in the same order.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            startGame();
                          },
                          child: Text('Start'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                isPlaying ? 'Restart' : 'Start',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print('Theme is ${Theme.of(context).brightness}');
          widget.changeTheme();
        },
        child: Icon(Icons.dark_mode_outlined),
      ),
    );
  }

  // Define the colorButton widget that will react based on colorFlashState
  Widget colorButton(String colorName, Color color, int index) {
    return GestureDetector(
      onTap: isPlayerTurn ? () => handlePlayerInput(colorName, index) : null,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFlashState[index], // Show color based on flash state
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            colorName,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: Colors.black54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startGame() {
    // print('Game Started');
    setState(() {
      round = 1;
      isPlaying = true;
      colorSequence.clear();
      userInput.clear();
    });
    // delay for 1 second before generating the sequence
    Timer(Duration(seconds: 1), () => generateSequence());
    // generateSequence(); // Generate sequence after game starts
  }

  void generateSequence() {
    List<String> colors = ['Red', 'Green', 'Blue', 'Yellow'];
    // print('Generate Sequence');

    // add 2 colors to the sequence after each round
    for (int i = 0; i < round; i++) {
      colorSequence.add(colors[Random().nextInt(4)]);
      // print('Color Sequence: $colorSequence');
    }

    // print(colorSequence);
    playSequence();
  }

  void playSequence() {
    setState(() {
      isPlayerTurn = false; // Disable user input while the sequence is playing
    });

    // Iterate over the colorSequence and flash each color
    for (int i = 0; i < colorSequence.length; i++) {
      Timer(Duration(seconds: i * 2), () {
        // Reset all containers to white
        setState(() {
          colorFlashState = [
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.white
          ];
          // Update the color container of the active button
          colorFlashState[getColorIndex(colorSequence[i])] =
              getColorFromName(colorSequence[i]);
        });

        // After a brief period, reset to white
        Timer(Duration(seconds: 1), () {
          setState(() {
            colorFlashState[getColorIndex(colorSequence[i])] = Colors.white;
          });
        });
      });
    }

    // After the entire sequence is played, allow the user to start playing
    Timer(Duration(seconds: colorSequence.length * 2), () {
      setState(() {
        isPlayerTurn = true; // Enable user input after the sequence has played
      });
    });
  }

  // Helper function to get the index of a color
  int getColorIndex(String colorName) {
    switch (colorName) {
      case 'Red':
        return 0;
      case 'Green':
        return 1;
      case 'Blue':
        return 2;
      case 'Yellow':
        return 3;
      default:
        return 0;
    }
  }

  // Function to map color names to actual Color objects
  Color getColorFromName(String colorName) {
    switch (colorName) {
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Blue':
        return Colors.blue;
      case 'Yellow':
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }

  // Function to handle the user's input and color change feedback
  void handlePlayerInput(String colorName, int index) {
    // Add the clicked color to the user input
    userInput.add(colorName);
    // print(userInput);

    // Show the clicked color for a brief moment
    setState(() {
      colorFlashState[index] = getColorFromName(colorName);
    });

    // Reset the clicked color to white after a brief moment (feedback effect)
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        colorFlashState[index] = Colors.white;
      });
    });

    // Check if the user has completed their input
    if (userInput.length == colorSequence.length) {
      if (userInput.join() == colorSequence.join()) {
        // print('Correct');
        setState(() {
          round++;
          // print('Round: $round');
          userInput.clear();
          isPlayerTurn = false;
          // add a delay before generating the next sequence
          Timer(Duration(seconds: 2), () {
            generateSequence();
          });
        });
      } else {
        // print('Wrong');
        // print('round: $round');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Game Over'),
              content: Text('You got to round $round.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      userInput.clear();
                      colorSequence.clear();
                      isPlaying = false;
                      round = 1;
                      isPlayerTurn = false;
                    });
                  },
                  child: Text('End'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
