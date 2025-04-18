import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';
import 'package:tetris_game/home_screen.dart';
import 'package:tetris_game/level_manager.dart';

/*

GAME BOARD

This is a 2x2 grid with null representing an empty space.
A non empty space will have the color to represent the landed pieces

*/

// create game board 
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
  rowLength,
  (j) => null,
  ),
  );

class GameBoard extends StatefulWidget {
  final int level;
  const GameBoard({Key? key, required this.level}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.L);

  //current score
  int currentScore = 0;

  // game over status
  bool gameOver = false;

  // pause state
  bool isPaused = false;
  Timer? gameTimer;

  // Add new variables for level tracking
  int currentLevel = 1;
  int requiredScore = 3;
  static const int linesPerLevel = 3;

  // Replace speed constants with level-specific speeds
  static const Map<int, int> LEVEL_SPEEDS = {
    1: 800,  // Level 1: 800ms
    2: 650,  // Level 2: 650ms
    3: 500,  // Level 3: 500ms
  };

  @override
  void initState() {
    super.initState();
    currentLevel = widget.level.clamp(1, 3);
    requiredScore = currentLevel * 3;
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();
    isPaused = false;

    // Update frame rate calculation
    updateGameSpeed();
  }

  // Update speed calculation method
  void updateGameSpeed() {
    int speed = LEVEL_SPEEDS[currentLevel] ?? 800;
    Duration frameRate = Duration(milliseconds: speed);
    gameLoop(frameRate);
  }

  //game loop
  void gameLoop(Duration frameRate) {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      frameRate, 
    (timer) {
      if (!isPaused) {
        setState(() {
          // clear lines
          clearLines();

          // check landing
          checkLanding();

          // check if game is over
          if (gameOver == true) {
            timer.cancel();
            showGameOverDialog();
          }

          // check if level is complete
          if (currentScore >= requiredScore) {
            timer.cancel();
            showLevelCompletionDialog();
          }

          //move current piece down
          currentPiece.movePiece(Direction.down);
        });
      }
    },
    );
  }

  // game over message
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text("Score: $currentScore\nLevel: $currentLevel"),
        actions: [
          TextButton(
            onPressed: () {
              // reset the game
              resetGame();

              Navigator.pop(context);
            },
            child: Text('Play Again'))
        ],
      ),
    );
  }

  // Modify startNextLevel method
  void startNextLevel() {
    setState(() {
      currentLevel = (currentLevel + 1).clamp(1, 3);
      currentScore = 0;
      requiredScore = currentLevel * 3;
      resetGame();
    });
  }

  // Update level completion dialog
  void showLevelCompletionDialog() {
    bool isLastLevel = currentLevel >= 3;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isLastLevel ? 'Game Completed!' : 'Level $currentLevel Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                currentLevel,
                (index) => Icon(Icons.star, color: Colors.yellow, size: 30),
              ),
            ),
            Text('Score: $currentScore'),
            if (isLastLevel) Text('\nCongratulations! You completed all levels!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            },
            child: Text('Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GameBoard(level: currentLevel),
                ),
              );
            },
            child: Text('Try Again'),
          ),
          if (!isLastLevel)
            TextButton(
              onPressed: () async {
                await LevelManager.unlockNextLevel(currentLevel);
                if (!mounted) return;
                startNextLevel();
                Navigator.pop(context);
              },
              child: Text('Next Level'),
            ),
        ],
      ),
    );
  }

  //reset game
  void resetGame() {
    gameTimer?.cancel();

    // clear the game board
    gameBoard = List.generate(
      colLength, 
      (i) => List.generate(
        rowLength, 
        (j) => null,
      ),
    );

    // new game 
    gameOver = false;
    currentScore = 0;

    // create new piece
    createNewPiece();

    // start game again
    startGame();
  }

  // check for collision in a future position
  // returns true -> there is a collision
  // returns false -> there is no collision
  bool checkCollision(Direction direction) {
    // loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      // calculate the row and column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // check if the piece is out of bounds (either too low or too far to the left or right)
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }
    
    // check if the current position is already occupied by another piece in the game board
    if (row >= 0 && col >= 0) {
      if (gameBoard[row][col] != null) {
        return true;
      }
    }
  }

     //if no collisions are detected, return false
      return false;
  }

  void checkLanding () {
    // if going down is occupied 
    if (checkCollision(Direction.down)) {
      // mark position as occupied on the gameboard
      for (int i=0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row>=0 && col>=0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      // once landed, create the next piece
      createNewPiece();
    }
  }

  void createNewPiece(){
    // create a random object to generate random tetromino types
    Random rand = Random();

    // create a new piece with random type
    Tetromino randomType = 
    Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    /*

    Since our game over condition is if there is a piece at the top level,
    you want to check if the game is over when you create a new piece
    instead of checking every frame, because new pieces are allowed to go through the top level
    but if there is already a piece in the top level when the new piece is created,
    then game is over 

    */
    if (isGameOver()) {
      gameOver = true;
    }
  }

  // move left
  void moveLeft() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  // move right
  void moveRight() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  //rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  // toggle pause
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }
 
 // clear lines 
  void clearLines() {
    int linesCleared = 0;
    
    // step 1: Loop through each row of the game board from the bottom to top
    for (int row = colLength - 1; row >= 0; row--) {
      // step 2: Initialize a variable to track if the row is full
      bool rowIsFull = true;

      // step 3: Check if the row is full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // If there's an empty column, set rowIsFull to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // step 4: If the row is full, clear the row and shift rows down
      if (rowIsFull) {
        // step 5: move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          //copy the row above to the current row
         gameBoard[r] = List.from(gameBoard[r - 1]); 
        }

        // step 6:  set the top row to empty
        gameBoard[0] = List.generate(rowLength, (index) => null);

        // step 7: Increment the score!
        currentScore++;
        linesCleared++;
      }
    }

    // Add level up logic
    if (linesCleared > 0 && currentScore >= (currentLevel * linesPerLevel)) {
      currentLevel++;
      updateGameSpeed();
    }
  }

  //GAME OVER METHOD
  bool isGameOver() {
    // check if any columns in the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true; 
    }
  }

  // if the top row is empty, the game is not over
  return false; 
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
            onPressed: togglePause,
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
        title: Text(
          isPaused ? 'Paused' : 'Playing',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                //GAME GRID
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GridView.builder(
                      itemCount: rowLength * colLength,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowLength),
                      itemBuilder: (context, index) { 
                        //get row and col of each index
                        int row = (index / rowLength).floor();
                        int col = index % rowLength;
                      
                        //current piece
                        if (currentPiece.position.contains(index)) {
                          return Pixel(
                            color:currentPiece.color, 
                            );
                        }
                      
                        // landed pieces
                        else if(gameBoard[row][col] != null){
                          final Tetromino? tetrominoType = gameBoard[row][col];
                          return Pixel(color:tetrominoColors[tetrominoType]);
                        }  
                        //blank pixel
                         else {
                          return Pixel(
                           color: Colors.grey[900],
                          );
                        }
                      },
                    ),
                  ),
                ),

                //SCORE AND LEVEL
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Score: $currentScore',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Level: $currentLevel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                //GAME CONTROLS
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // left
                      IconButton(
                        onPressed: moveLeft,
                        color: Colors.white,
                        icon: Icon(Icons.arrow_back_ios),
                        ),
                      
                      //rotate
                      IconButton(
                        onPressed: rotatePiece,
                        color: Colors.white, 
                        icon: Icon(Icons.rotate_right),
                        ),
                  
                      //right
                      IconButton(
                        onPressed: moveRight,
                        color: Colors.white, 
                        icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                  ),
                )
              ],
            ),
            if (isPaused)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PAUSED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: togglePause,
                        child: Text('Resume Game'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


