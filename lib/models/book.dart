class Book {
  final String id;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String coverImageUrl;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? swapOfferId; // null if available, otherwise ID of the swap offer
  final String swapStatus; // Available, Pending, Accepted, Rejected

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.coverImageUrl,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
    this.swapOfferId,
    this.swapStatus = 'Available',
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'coverImageUrl': coverImageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'swapOfferId': swapOfferId,
      'swapStatus': swapStatus,
    };
  }

  // Create from Firestore Map
  factory Book.fromFirestore(Map<String, dynamic> data, String id) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: data['condition'] ?? 'Used',
      coverImageUrl: data['coverImageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
      swapOfferId: data['swapOfferId'],
      swapStatus: data['swapStatus'] ?? 'Available',
    );
  }

  // Create a copy with updated fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? coverImageUrl,
    String? ownerId,
    String? ownerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? swapOfferId,
    String? swapStatus,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      swapOfferId: swapOfferId ?? this.swapOfferId,
      swapStatus: swapStatus ?? this.swapStatus,
    );
  }
}

