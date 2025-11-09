import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload book cover image (for mobile/desktop)
  Future<String> uploadBookCover(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'book_covers/${user.uid}_$timestamp.jpg';

    try {
      final ref = _storage.ref().child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      await ref.putFile(imageFile, metadata);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        throw Exception('Storage permission denied. Please check your Firebase Storage security rules.');
      } else if (e.code == 'canceled') {
        throw Exception('Upload was canceled.');
      } else {
        throw Exception('Failed to upload image: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload book cover image from bytes (for web)
  Future<String> uploadBookCoverFromBytes(Uint8List imageBytes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'book_covers/${user.uid}_$timestamp.jpg';

    try {
      final ref = _storage.ref().child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      await ref.putData(imageBytes, metadata);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        throw Exception('Storage permission denied. Please check your Firebase Storage security rules.');
      } else if (e.code == 'canceled') {
        throw Exception('Upload was canceled.');
      } else {
        throw Exception('Failed to upload image: ${e.message ?? e.code}');
      }
    } catch (e) {
      // Check if it's a CORS error (common on web)
      if (e.toString().contains('CORS') || e.toString().contains('cors')) {
        throw Exception('CORS error: Please configure Firebase Storage CORS settings. See FIREBASE_SETUP.md for instructions.');
      }
      throw Exception('Failed to upload image: $e');
    }
  }
}

