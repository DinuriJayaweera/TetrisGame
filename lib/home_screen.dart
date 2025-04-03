import 'package:flutter/material.dart';
import 'package:tetris_game/board.dart';
import 'package:tetris_game/level_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> unlockedLevels = [true];

  @override
  void initState() {
    super.initState();
    _loadUnlockedLevels();
  }

  Future<void> _loadUnlockedLevels() async {
    final levels = await LevelManager.getUnlockedLevels();
    setState(() {
      unlockedLevels = levels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Tetris Levels'),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: LevelManager.maxLevels,
        itemBuilder: (context, index) {
          final level = index + 1;
          final isUnlocked = index < unlockedLevels.length && unlockedLevels[index];
          
          return GestureDetector(
            onTap: isUnlocked ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameBoard(level: level),
                ),
              );
            } : null,
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Level $level',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
