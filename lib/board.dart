import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';


class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piecce
  Piece currentPiece = Piece(type: Tetromino.T);

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
        //move current piece down
        currentPiece.movePiece(Direction.down);
      });
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.builder(
        itemCount: rowLength * colLength,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowLength,
        ),
        itemBuilder: (context, index) {
          if (currentPiece.position.contains(index)) {
            return Pixel(
              color: Colors.yellow, 
              child: index,
              );
          } else {
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
