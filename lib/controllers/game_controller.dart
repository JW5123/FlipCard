import 'dart:async';
import 'dart:math';

import '../models/card_model.dart';

class GameController {
  final List<String> imagePaths;
  late List<CardModel> cards;

  int? firstFlippedIndex;
  bool isBusy = false;
  bool timerStarted = false;
  int secondsPassed = 0;
  Timer? _timer;

  GameController({required this.imagePaths}) {
    resetGame();
  }

  void resetGame() {
    final temp = <CardModel>[];
    for (var path in imagePaths) {
      temp.add(CardModel(imagePath: path));
      temp.add(CardModel(imagePath: path));
    }
    temp.shuffle(Random());

    cards = temp;
    firstFlippedIndex = null;
    isBusy = false;
    secondsPassed = 0;
    timerStarted = false;
    _timer?.cancel();
  }

  void startTimer(void Function() onTick) {
    if (timerStarted) return;
    timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsPassed++;
      onTick();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    timerStarted = false;
  }

  Future<void> onCardTapped(int index, void Function() updateUI) async {
    if (isBusy || cards[index].isMatched || cards[index].isFlipped) return;

    if (!timerStarted) startTimer(updateUI);

    cards[index].isFlipped = true;
    updateUI();

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
    } else {
      final secondIndex = index;
      final firstCard = cards[firstFlippedIndex!];
      final secondCard = cards[secondIndex];

      if (firstCard.imagePath == secondCard.imagePath) {
        isBusy = true;
        await Future.delayed(const Duration(milliseconds: 100));
        firstCard.isMatched = true;
        secondCard.isMatched = true;
        isBusy = false;
      } else {
        isBusy = true;
        await Future.delayed(const Duration(milliseconds: 200));
        firstCard.isFlipped = false;
        secondCard.isFlipped = false;
        isBusy = false;
      }
      firstFlippedIndex = null;
      updateUI();
    }

    // 遊戲結束 → 停止計時
    if (cards.every((c) => c.isMatched)) {
      stopTimer();
    }
  }
}
