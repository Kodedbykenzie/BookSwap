import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============ BOOK LISTINGS ============

  // Create a new book listing
  Future<String> createBook({
    required String title,
    required String author,
    required String condition,
    required String coverImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final bookData = {
      'title': title,
      'author': author,
      'condition': condition,
      'coverImageUrl': coverImageUrl,
      'ownerId': user.uid,
      'ownerEmail': user.email ?? '',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'swapOfferId': null,
      'swapStatus': 'Available',
    };

    final docRef = await _firestore.collection('books').add(bookData);
    return docRef.id;
  }

  // Get all available books (for browsing)
  Stream<List<Book>> getAvailableBooks() {
    return _firestore
        .collection('books')
        .where('swapStatus', isEqualTo: 'Available')
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => Book.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt descending
      books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return books;
    });
  }

  // Get books by owner
  Stream<List<Book>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => Book.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt descending
      books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return books;
    });
  }

  // Get a single book by ID
  Future<Book?> getBookById(String bookId) async {
    final doc = await _firestore.collection('books').doc(bookId).get();
    if (!doc.exists) return null;
    return Book.fromFirestore(doc.data()!, doc.id);
  }

  // Update a book listing
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? condition,
    String? coverImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final book = await getBookById(bookId);
    if (book == null) throw Exception('Book not found');
    if (book.ownerId != user.uid) throw Exception('Not authorized to edit this book');

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (title != null) updates['title'] = title;
    if (author != null) updates['author'] = author;
    if (condition != null) updates['condition'] = condition;
    if (coverImageUrl != null) updates['coverImageUrl'] = coverImageUrl;

    await _firestore.collection('books').doc(bookId).update(updates);
  }

  // Delete a book listing
  Future<void> deleteBook(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final book = await getBookById(bookId);
    if (book == null) throw Exception('Book not found');
    if (book.ownerId != user.uid) throw Exception('Not authorized to delete this book');

    await _firestore.collection('books').doc(bookId).delete();
  }

  // ============ SWAP OFFERS ============

  // Create a swap offer
  Future<String> createSwapOffer(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final book = await getBookById(bookId);
    if (book == null) throw Exception('Book not found');
    if (book.ownerId == user.uid) throw Exception('Cannot swap your own book');
    if (book.swapStatus != 'Available') throw Exception('Book is not available for swap');

    final now = DateTime.now();
    final swapOfferData = {
      'bookId': bookId,
      'bookTitle': book.title,
      'bookAuthor': book.author,
      'bookCoverImageUrl': book.coverImageUrl,
      'fromUserId': user.uid,
      'fromUserEmail': user.email ?? '',
      'toUserId': book.ownerId,
      'toUserEmail': book.ownerEmail,
      'status': 'Pending',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    final swapOfferRef = await _firestore.collection('swapOffers').add(swapOfferData);
    final swapOfferId = swapOfferRef.id;

    // Update the book's swap status
    await _firestore.collection('books').doc(bookId).update({
      'swapStatus': 'Pending',
      'swapOfferId': swapOfferId,
      'updatedAt': now.toIso8601String(),
    });

    return swapOfferId;
  }

  // Get swap offers where user is the recipient
  Stream<List<SwapOffer>> getIncomingSwapOffers() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('swapOffers')
        .where('toUserId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final offers = snapshot.docs
          .map((doc) => SwapOffer.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt descending
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return offers;
    });
  }

  // Get swap offers where user is the sender
  Stream<List<SwapOffer>> getOutgoingSwapOffers() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('swapOffers')
        .where('fromUserId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final offers = snapshot.docs
          .map((doc) => SwapOffer.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt descending
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return offers;
    });
  }

  // Get all swap offers for a user (both incoming and outgoing)
  Stream<List<SwapOffer>> getAllSwapOffers() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // Query offers where user is the sender
    final outgoingStream = _firestore
        .collection('swapOffers')
        .where('fromUserId', isEqualTo: user.uid)
        .snapshots();
    
    // Query offers where user is the recipient
    final incomingStream = _firestore
        .collection('swapOffers')
        .where('toUserId', isEqualTo: user.uid)
        .snapshots();

    // Combine both streams properly
    StreamController<List<SwapOffer>> controller = StreamController<List<SwapOffer>>.broadcast();
    List<SwapOffer> lastOutgoing = [];
    List<SwapOffer> lastIncoming = [];
    bool outgoingInitialized = false;
    bool incomingInitialized = false;

    void combineAndEmit() {
      if (outgoingInitialized && incomingInitialized) {
        final allOffers = <SwapOffer>[];
        allOffers.addAll(lastOutgoing);
        allOffers.addAll(lastIncoming);
        
        // Filter to only show Pending or Accepted offers
        final filtered = allOffers.where((offer) =>
            offer.status == 'Pending' || offer.status == 'Accepted').toList();
        controller.add(filtered);
      }
    }

    outgoingStream.listen((snapshot) {
      lastOutgoing = snapshot.docs
          .map((doc) => SwapOffer.fromFirestore(doc.data(), doc.id))
          .toList();
      outgoingInitialized = true;
      combineAndEmit();
    }, onError: (error) => controller.addError(error));

    incomingStream.listen((snapshot) {
      lastIncoming = snapshot.docs
          .map((doc) => SwapOffer.fromFirestore(doc.data(), doc.id))
          .toList();
      incomingInitialized = true;
      combineAndEmit();
    }, onError: (error) => controller.addError(error));

    return controller.stream;
  }

  // Update swap offer status
  Future<void> updateSwapOfferStatus(String swapOfferId, String status) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final swapOfferDoc = await _firestore.collection('swapOffers').doc(swapOfferId).get();
    if (!swapOfferDoc.exists) throw Exception('Swap offer not found');

    final swapOffer = SwapOffer.fromFirestore(swapOfferDoc.data()!, swapOfferId);

    // Only the recipient can accept/reject
    if (swapOffer.toUserId != user.uid) {
      throw Exception('Not authorized to update this swap offer');
    }

    if (status != 'Accepted' && status != 'Rejected') {
      throw Exception('Invalid status');
    }

    final now = DateTime.now();

    // Update swap offer
    await _firestore.collection('swapOffers').doc(swapOfferId).update({
      'status': status,
      'updatedAt': now.toIso8601String(),
    });

    // Update book status
    await _firestore.collection('books').doc(swapOffer.bookId).update({
      'swapStatus': status,
      'updatedAt': now.toIso8601String(),
    });
  }

  // ============ CHAT ============

  // Get or create a chat ID between two users
  String getChatId(String userId1, String userId2) {
    // Sort user IDs to ensure consistent chat ID regardless of order
    final sortedIds = [userId1, userId2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Send a message
  Future<void> sendMessage({
    required String receiverId,
    required String receiverEmail,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final chatId = getChatId(user.uid, receiverId);
    final now = DateTime.now();

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'chatId': chatId,
      'senderId': user.uid,
      'senderEmail': user.email ?? '',
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': now.toIso8601String(),
    });
  }

  // Get messages for a chat
  Stream<List<ChatMessage>> getChatMessages(String otherUserId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final chatId = getChatId(user.uid, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get all chats for current user
  Stream<List<String>> getUserChats() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // Get all chats where user is either sender or receiver
    return _firestore
        .collection('chats')
        .snapshots()
        .map((snapshot) {
      final chatIds = <String>{};
      for (final chatDoc in snapshot.docs) {
        final chatId = chatDoc.id;
        // Check if this chat has messages with current user
        // We'll need to check messages to see if user is involved
        chatIds.add(chatId);
      }
      return chatIds.toList();
    });
  }

  // Get chat participants from messages
  Future<String?> getOtherUserIdFromChat(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .limit(1)
        .get();

    if (messagesSnapshot.docs.isEmpty) return null;

    final message = ChatMessage.fromFirestore(
        messagesSnapshot.docs.first.data(), messagesSnapshot.docs.first.id);

    return message.senderId == user.uid ? message.receiverId : message.senderId;
  }
}

