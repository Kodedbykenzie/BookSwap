class SwapOffer {
  final String id;
  final String bookId; // The book being offered
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverImageUrl;
  final String fromUserId; // User making the offer
  final String fromUserEmail;
  final String toUserId; // Owner of the book
  final String toUserEmail;
  final String status; // Pending, Accepted, Rejected
  final DateTime createdAt;
  final DateTime updatedAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverImageUrl,
    required this.fromUserId,
    required this.fromUserEmail,
    required this.toUserId,
    required this.toUserEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverImageUrl': bookCoverImageUrl,
      'fromUserId': fromUserId,
      'fromUserEmail': fromUserEmail,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory SwapOffer.fromFirestore(Map<String, dynamic> data, String id) {
    return SwapOffer(
      id: id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookAuthor: data['bookAuthor'] ?? '',
      bookCoverImageUrl: data['bookCoverImageUrl'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      fromUserEmail: data['fromUserEmail'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toUserEmail: data['toUserEmail'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

