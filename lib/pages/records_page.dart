import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/game_record.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<GameRecord> _records = [];
  GameRecord? _bestRecord;
  int _totalGames = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _databaseHelper.getAllGameRecords();
      final bestRecord = await _databaseHelper.getBestRecord();
      final totalGames = await _databaseHelper.getTotalGames();

      setState(() {
        _records = records;
        _bestRecord = bestRecord;
        _totalGames = totalGames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('載入記錄時發生錯誤：$e');
    }
  }

  Future<void> _onRefresh() async {
    await _loadRecords();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認清除'),
        content: const Text('確定要清除所有記錄嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _databaseHelper.clearAllRecords();
              _loadRecords();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('所有記錄已清除')),
              );
            },
            child: const Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間記錄'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('清除所有記錄'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  // 統計資訊卡片
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('總遊戲次數', '$_totalGames 次', Icons.games),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.teal.shade300,
                        ),
                        _buildStatItem(
                          '最佳成績',
                          _bestRecord?.formattedTime ?? '--:--',
                          Icons.timer,
                        ),
                      ],
                    ),
                  ),
                  
                  // 記錄列表
                  Expanded(
                    child: _records.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '尚無記錄',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              final isToday = _isToday(record.dateTime);
                              final isBest = _bestRecord != null &&
                                  record.secondsSpent == _bestRecord!.secondsSpent;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isBest
                                        ? Colors.amber
                                        : isToday
                                            ? Colors.teal
                                            : Colors.grey.shade300,
                                    child: Icon(
                                      isBest
                                          ? Icons.emoji_events
                                          : isToday
                                              ? Icons.today
                                              : Icons.access_time,
                                      color: isBest || isToday
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        record.formattedTime,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: isBest ? Colors.amber.shade700 : null,
                                        ),
                                      ),
                                      if (isBest) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.emoji_events,
                                          size: 16,
                                          color: Colors.amber.shade700,
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '日期：${record.formattedDate}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      Text(
                                        '時間：${record.formattedClock}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    '#${index + 1}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.teal.shade700,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}