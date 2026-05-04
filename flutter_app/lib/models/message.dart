class Message {
  final int id;
  final int matchId;
  final int senderId;
  final String messageText;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.messageText,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      matchId: json['match']['id'],
      senderId: json['sender']['id'],
      messageText: json['messageText'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
