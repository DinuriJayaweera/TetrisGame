// grid dimensions

import 'package:flutter/material.dart';

int rowLength = 10;
int colLength = 15;

enum Direction { 
  left,
  right,
  down,
}

enum Tetromino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,

  /*

  o
  o
  o o
  
    o
    o
  o o

  o
  o
  o
  o

  o  o
  o  o

     o o
  o  o

  o o
    o  o

    o
    o  o
    o

    */
}

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Color(0XFFFFA500),
  Tetromino.J: Color.fromARGB(255, 0, 102, 255),
  Tetromino.I: Color.fromARGB(255, 242, 0, 255),
  Tetromino.O: Color(0XFFFFFF00),
  Tetromino.S: Color(0XFF008000),
  Tetromino.Z: Color(0XFFFF0000),
  Tetromino.T: Color.fromRGBO(156, 39, 176, 1),
};