import 'package:shared_preferences/shared_preferences.dart';

class LevelManager {
  static const int maxLevels = 3;
  static const String unlockedLevelsKey = 'unlockedLevels';
  
  static Map<int, int> levelRequirements = {
    1: 3,  // Level 1 requires 3 points
    2: 5,  // Level 2 requires 5 points
    3: 7,  // Level 3 requires 7 points
  };

  static Future<List<bool>> getUnlockedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedList = prefs.getStringList(unlockedLevelsKey) ?? ['true'];
    return unlockedList.map((e) => e == 'true').toList();
  }

  static Future<void> unlockNextLevel(int currentLevel) async {
    if (currentLevel >= maxLevels) return;
    
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedList = prefs.getStringList(unlockedLevelsKey) ?? ['true'];
    
    if (currentLevel < unlockedList.length) {
      unlockedList[currentLevel] = 'true';
    } else {
      unlockedList.add('true');
    }
    
    await prefs.setStringList(unlockedLevelsKey, unlockedList);
  }
}
