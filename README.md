# 📚 BookSwap

**BookSwap** is a Flutter-based mobile application that allows users to list their books, manage swap offers, and connect with other book lovers. The app integrates **Firebase Authentication**, **Cloud Firestore**, and **Firebase Storage** to provide a seamless and interactive experience.



## 🧩 Features

* **User Authentication**: Sign up, log in, and log out securely using Firebase Auth.
* **Book Listings**: Add, edit, and delete books with images and conditions.
* **Swap Offers**: Receive, accept, or reject swap offers from other users.
* **Responsive UI**: Supports both mobile and web platforms.
* **Splash Screen**: Animated splash screen on app launch.


 ⚙️ Getting Started

### Prerequisites

* Flutter SDK >= 3.x
* Firebase account
* VS Code or Android Studio

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/Kodedbykenzie/BookSwap.git
cd BookSwap
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

   * Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
   * Update `firebase_options.dart` using `flutterfire configure`

4. **Run the app**

```bash
flutter run
```



## 🛠 Tech Stack

* Flutter
* Dart
* Firebase (Auth, Firestore, Storage)
* Riverpod (State Management)



## 📝 Folder Structure

```
lib/
├─ main.dart
├─ screens/
│  ├─ splash_screen.dart
│  ├─ login_screen.dart
│  ├─ signup_screen.dart
│  └─ my_listings_screen.dart
├─ services/
│  ├─ auth_service.dart
│  ├─ firestore_service.dart
│  ├─ storage_service.dart
│  └─ preferences_service.dart
├─ models/
│  ├─ book.dart
│  └─ swap_offer.dart
└─ widgets/
```



## 🔗 GitHub Repository

[BookSwap on GitHub](https://github.com/Kodedbykenzie/BookSwap.git)



## 🙏 Credits

* Developed by **Kodedbykenzie**




