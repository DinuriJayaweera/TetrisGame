import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';
import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';

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
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piecce
  Piece currentPiece = Piece(type: Tetromino.Z);

  @override
  void initState() {
    super.initState();

    // startt game when app starts
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    //frame refresh rate
    Duration frameRate = const Duration(milliseconds: 800);
    gameLoop(frameRate);
  }

  //game loop
  void gameLoop(Duration frameRate) {
    Timer.periodic(
      frameRate, 
    (timer) {
      setState(() {
        // check landing
        checkLanding();

        //move current piece down
        currentPiece.movePiece(Direction.down);
      });
    },
    );
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

      // once landed, creaate the next piece
      createNewPiece();
    }
  }

  void createNewPiece(){
    // create a random object to generate random tetroimino types
    Random rand = Random();

    // create a new piece with random type
    Tetromino randomType = 
    Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.builder(
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
              child: index,
              );
          }

          // landed pieces
          else if(gameBoard[row][col] != null){
            final Tetromino? tetrominoType = gameBoard[row][col];
            return Pixel(color:tetrominoColors[tetrominoType], child: '');
          }
          //blank pixel
           else {
            return Pixel(
             color: Colors.grey[900],
             child: index,
            );
          }
        },
      ),
    );
  }
}
