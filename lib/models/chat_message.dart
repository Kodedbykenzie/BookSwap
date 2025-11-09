class ChatMessage {
  final String id;
  final String chatId; // ID of the chat conversation
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    required this.message,
    required this.timestamp,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverEmail: data['receiverEmail'] ?? '',
      message: data['message'] ?? '',
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

