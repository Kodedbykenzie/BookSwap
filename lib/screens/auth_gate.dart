import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// --- Import your real screens ---
import 'login_screen.dart';
import 'main_app_screen.dart'; // <-- This is your new BottomNavBar screen!

import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/preferences_service.dart';

// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Provider for PreferencesService
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

// Stream provider to listen to auth changes
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        } else {
          // User is logged in!
          return const MainAppScreen(); 
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text("Error: $error")),
      ),
    );
  }
}