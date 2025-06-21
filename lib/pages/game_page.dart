import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';

class FlipCardGamePage extends StatefulWidget {
  const FlipCardGamePage({super.key});

  @override
  State<FlipCardGamePage> createState() => _FlipCardGamePageState();
}

class _FlipCardGamePageState extends State<FlipCardGamePage> {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(imagePaths: [
      'assets/images/card1.png',
      'assets/images/card2.png',
      'assets/images/card3.png',
      'assets/images/card4.png',
      'assets/images/card5.png',
      'assets/images/card6.png',
    ]);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('翻牌遊戲')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '⏱ 時間：${_formatTime(controller.secondsPassed)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final card = controller.cards[index];
                return GestureDetector(
                  onTap: () => controller.onCardTapped(index, () => setState(() {})),
                  child: card.isMatched
                      ? const SizedBox.shrink()
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(
                                card.isFlipped
                                    ? card.imagePath
                                    : 'assets/images/card_back.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  controller.resetGame();
                });
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text("重新開始"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
