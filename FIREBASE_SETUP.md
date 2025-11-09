# Firebase Setup Instructions for BookSwap

## Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project" or "Create a project"
3. Enter project name: **bookswap** (or your preferred name)
4. Follow the setup wizard:
   - Enable Google Analytics (optional)
   - Complete setup

## Step 2: Configure Flutter with Firebase
1. Install FlutterFire CLI (if not already installed):
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Navigate to your Flutter project:
   ```bash
   cd bookswap
   ```

3. Configure Firebase for your Flutter app:
   ```bash
   flutterfire configure
   ```
   
   When prompted:
   - Select your Firebase project (bookswap)
   - Select platforms: Android, iOS, Web, Windows (or all)
   - The CLI will automatically update `firebase_options.dart`

## Step 3: Initialize Firebase Services
1. Enable Firestore Database:
   - Go to Firebase Console → Firestore Database
   - Click "Create database"
   - Start in **test mode** (for development)
   - Choose a location

2. Enable Authentication:
   - Go to Firebase Console → Authentication
   - Click "Get started"
   - Enable "Email/Password" sign-in method

3. Enable Storage (for book cover images):
   - Go to Firebase Console → Storage
   - Click "Get started"
   - Choose "Start in test mode" (for development)
   - Choose a location

## Step 4: Configure Storage CORS (Required for Web Uploads)
Firebase Storage requires CORS configuration for web uploads. **This is required for web uploads to work!**

### Method 1: Using gsutil (Recommended)

#### Windows Installation:
1. **Download Google Cloud SDK for Windows:**
   - Go to: https://cloud.google.com/sdk/docs/install-sdk#windows
   - Download the installer (`.exe` file)
   - Run the installer and follow the prompts
   - Make sure to check "Add gcloud to PATH" during installation

2. **After installation, open a NEW PowerShell/Command Prompt** (to refresh PATH)

3. **Authenticate with Google Cloud:**
   ```powershell
   gcloud auth login
   ```
   This will open your browser to sign in with your Google account (use the same account as Firebase)

4. **Set your project:**
   ```powershell
   gcloud config set project bookswap-751e6
   ```
   (Replace `bookswap-751e6` with your actual project ID)

5. **Apply CORS configuration:**
   ```powershell
   gsutil cors set storage.cors.json gs://bookswap-751e6.firebasestorage.app
   ```
   (Replace `bookswap-751e6` with your actual storage bucket name)
   
   **Note**: Your storage bucket name is in `firebase_options.dart` as `storageBucket` (e.g., `bookswap-751e6.firebasestorage.app`)

6. **Verify CORS is set:**
   ```powershell
   gsutil cors get gs://bookswap-751e6.firebasestorage.app
   ```
   This should display the CORS configuration from `storage.cors.json`

#### Mac/Linux Installation:
```bash
# Install via Homebrew (Mac) or package manager
# Then follow steps 3-6 above
```

### Method 2: Using Google Cloud Console (Web Interface)

If you can't install gsutil, you can use the Google Cloud Console:

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Select your project: `bookswap-751e6`

2. **Navigate to Cloud Storage:**
   - Go to "Cloud Storage" → "Buckets"
   - Find your bucket: `bookswap-751e6.firebasestorage.app`
   - Click on the bucket name

3. **Configure CORS:**
   - Click on the "Configuration" tab
   - Scroll to "Cross-origin resource sharing (CORS)"
   - Click "Edit CORS configuration"
   - Paste the contents of `storage.cors.json` (the array part):
     ```json
     [
       {
         "origin": ["*"],
         "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
         "maxAgeSeconds": 3600,
         "responseHeader": ["Content-Type", "Authorization", "Content-Length", "User-Agent", "x-goog-resumable"]
       }
     ]
     ```
   - Click "Save"

**Important**: CORS configuration cannot be done through Firebase Console directly - you must use either gsutil or Google Cloud Console.

## Step 5: Deploy Firestore Rules
1. Make sure you're logged in:
   ```bash
   firebase login
   ```

2. Initialize Firebase (if not done):
   ```bash
   firebase init firestore
   ```
   - Select your project
   - Use existing `firestore.rules` file

3. Deploy rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

## Step 6: Configure Storage Security Rules
1. Go to Firebase Console → Storage → Rules
2. Update the rules to allow authenticated users to upload and read:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /book_covers/{allPaths=**} {
         // Allow authenticated users to read and write book covers
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
3. Click "Publish" to deploy the rules

## Step 7: Update Project ID
After running `flutterfire configure`, your `firebase_options.dart` will be automatically updated with the correct project ID.

The `firebase.json` should only contain:
```json
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
```

And `.firebaserc` should contain:
```json
{
  "projects": {
    "default": "your-project-id"
  }
}
```

## Alternative: Manual Setup
If you already have a Firebase project and want to use it:

1. Get your Firebase project configuration from Console
2. Run `flutterfire configure` and select your existing project
3. Or manually update `firebase_options.dart` with your project details

## Troubleshooting Common Errors

### 1. CORS Error (Firebase Storage)
**Error**: `Access to XMLHttpRequest... blocked by CORS policy`

**Solution**: 
- **If gsutil is not installed**: Use Method 2 in Step 4 (Google Cloud Console web interface)
- **If gsutil is installed**: Run: `gsutil cors set storage.cors.json gs://YOUR-BUCKET-NAME.firebasestorage.app`
- Verify your bucket name matches the one in `firebase_options.dart`
- After configuring, clear browser cache and reload the app
- **Note**: You must configure CORS for web uploads to work - this is required!

### 2. Authentication 400 Error
**Error**: `POST .../accounts:signInWithPassword 400 (Bad Request)`

**Possible Causes**:
- Wrong email or password
- User account doesn't exist (try signing up first)
- Email not verified (if email verification is required)

**Solution**: 
- Double-check your credentials
- Try creating a new account via the sign-up screen
- Check Firebase Console → Authentication to see if users exist

### 3. Firestore 400 Error
**Error**: `POST .../Firestore/Write/channel 400 (Bad Request)`

**Possible Causes**:
- Firestore security rules blocking the operation
- Missing required fields in the document
- User not authenticated

**Solution**:
- Make sure Firestore rules are deployed: `firebase deploy --only firestore:rules`
- Check Firebase Console → Firestore → Rules to verify rules are correct
- Ensure user is logged in before performing operations

### 4. Storage Upload Fails
**Error**: `Failed to upload image` or permission errors

**Solution**:
- Verify Storage security rules allow authenticated users (Step 6 above)
- Check Firebase Console → Storage → Rules
- Ensure CORS is configured (Step 4 above)
- Make sure user is authenticated before uploading

### 5. Rules Not Working
**Error**: Operations fail even with correct rules

**Solution**:
- Redeploy rules: `firebase deploy --only firestore:rules`
- Clear browser cache and reload
- Check Firebase Console to verify rules are deployed
- Wait a few minutes for rules to propagate

## Quick Verification Checklist

After setup, verify:
- [ ] Firestore rules deployed
- [ ] Storage rules configured in Firebase Console
- [ ] Storage CORS configured via gsutil
- [ ] Authentication enabled with Email/Password
- [ ] User can sign up and sign in
- [ ] User can upload images (if CORS is configured)
- [ ] User can create books and swap offers

