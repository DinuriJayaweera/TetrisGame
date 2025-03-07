import 'package:flutter/services.dart';

import 'values.dart';

class Piece {
  // type of tetris piece
  Tetromino type;

  Piece({required this.type});

  // the piece is just a list of integers
  List<int> position = [];

  // generate the integers
  void initializePiece() {
    switch (type) {
      case Tetromino.L:
        position = [
         4,
         14,
         24,
         25,
        ];
        break;
      default:
    }
  }
  
  // move piece
  void movePiece(Direction direction) {
    switch (direction) {
      case Direction.down:
      for(int i = 0; i < position.length; i++) {
        position[i] += rowLength;
       } 
       break;
       case Direction.left:
      for(int i = 0; i < position.length; i++) {
        position[i] -= 1;
       } 
       break;
       case Direction.right:
      for(int i = 0; i < position.length; i++) {
        position[i] += 1;
       } 
       break;
      default:
    } 
  }
}