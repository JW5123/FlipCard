class GameRecord {
  final int? id;
  final DateTime dateTime;
  final int secondsSpent;

  GameRecord({
    this.id,
    required this.dateTime,
    required this.secondsSpent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'secondsSpent': secondsSpent,
    };
  }

  // 從 Map 建立 GameRecord
  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      id: map['id'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      secondsSpent: map['secondsSpent'],
    );
  }

  String get formattedTime {
    final minutes = (secondsSpent ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsSpent % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedDate {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  String get formattedClock {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}