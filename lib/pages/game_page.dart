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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _showGameCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('恭喜完成！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                children: [
                  const Text('完成時間', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    _formatTime(controller.secondsPassed),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('記錄已自動儲存到歷史記錄中', 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    controller.resetGame();
                  });
                },
                child: const Text('再玩一次'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('確定'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 檢查遊戲是否完成
    if (controller.cards.isNotEmpty && 
        controller.cards.every((c) => c.isMatched) && 
        controller.secondsPassed > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameCompletedDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('翻牌記憶'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // 時間顯示
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.teal.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '時間：${_formatTime(controller.secondsPassed)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          
          // 遊戲網格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final card = controller.cards[index];
                return GestureDetector(
                  onTap: () => controller.onCardTapped(index, () => setState(() {})),
                  child: Container(
                    // duration: const Duration(milliseconds: 100), // AnimatedContainer
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(12),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.1),
                      //     blurRadius: 4,
                      //     offset: const Offset(0, 2),
                      //   ),
                      // ],
                      image: card.isMatched
                          ? null
                          : DecorationImage(
                              image: AssetImage(
                                card.isFlipped
                                    ? card.imagePath
                                    : 'assets/images/card_back.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: card.isMatched
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.green.shade100,
                              border: Border.all(color: Colors.green.shade300, width: 2),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 40,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          
          // 重新開始按鈕
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  controller.resetGame();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('遊戲已重新開始'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text("重新開始"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}