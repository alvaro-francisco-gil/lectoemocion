# 🔥 Firebase Setup Guide for LectoEmoción

## ✅ What You Have Working

Your Firebase project is correctly configured and you have:

- ✅ **Real Firebase Authentication** with email/password
- ✅ **Profile system** integrated into your game
- ✅ **User registration and login** working
- ✅ **Session persistence** across app restarts
- ✅ **Google Sign-in enabled** in Firebase Console

## 🔧 To Complete Google Sign-in Setup

### Step 1: Get Your Google Client ID

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **lectoemocion-game**
3. Go to **Authentication** > **Sign-in method**
4. Click on **Google** provider
5. You'll see:
   - **Web client ID**: `718149941592-XXXXXXXXXX.apps.googleusercontent.com`
   - **Web client secret**: (keep this secret)

### Step 2: Update Your Godot Project

1. Open `scripts/shared/firebase_config.gd`
2. Replace this line:
   ```gdscript
   const GOOGLE_CLIENT_ID = "718149941592-YOUR_CLIENT_ID.apps.googleusercontent.com"
   ```
   With your actual client ID:
   ```gdscript
   const GOOGLE_CLIENT_ID = "718149941592-XXXXXXXXXX.apps.googleusercontent.com"
   ```

### Step 3: Google Sign-in Implementation

For full Google Sign-in support, you would need to:

1. **Web Export**: Use JavaScript to open Google OAuth popup
2. **Desktop Export**: Use OS.shell_open() to open browser
3. **Mobile Export**: Use platform-specific OAuth libraries

**For now**, the system shows a message that Google Sign-in needs additional setup.

## 🎮 How to Test Your Current Setup

1. **Run your project**
2. **Click "👤 Perfil"**
3. **Register a new account** with:
   - Email: `test@lectoemocion.com`
   - Password: `123456`
   - Name: `Test User`
4. **Login with your account**
5. **See your name** in the profile button

## 📊 Firebase Console Features You Can Use

### Authentication Tab
- **Users**: See all registered users
- **Sign-in method**: Manage providers
- **Settings**: Configure email templates
- **Usage**: Monitor authentication usage

### Realtime Database (Optional)
- Store user progress and game data
- Real-time synchronization across devices

### Analytics (Already configured)
- Track user engagement
- Monitor app performance

## 🚀 Current Features

### ✅ Working
- Email/password registration
- Email/password login
- User profile display
- Session persistence
- Password reset (via Firebase email)
- Profile updates
- Logout functionality

### 🔄 In Progress
- Google Sign-in (requires client ID setup)
- User progress tracking
- Cross-device synchronization

## 🛠️ Technical Details

### Firebase REST API
Your authentication uses Firebase REST API endpoints:
- Registration: `https://identitytoolkit.googleapis.com/v1/accounts:signUp`
- Login: `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword`
- Password Reset: `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode`

### Error Handling
User-friendly Spanish error messages for:
- Invalid email/password
- Email already exists
- Weak passwords
- Network errors
- And more...

### Security
- Passwords handled by Firebase (never stored locally)
- Secure token-based authentication
- Session tokens with automatic refresh
- Firebase security rules (when you add database)

## 📝 Next Steps

1. **Get Google Client ID** (5 minutes)
2. **Test email authentication** (works now)
3. **Optional**: Add Firestore for user progress
4. **Optional**: Add Cloud Storage for user content
5. **Optional**: Add Analytics events for game actions

Your Firebase integration is production-ready for email authentication! 🎉 