# 🎮 LectoEmoción - Educational Minigames

A collection of educational minigames built with Godot 4, designed to help children learn reading and emotional skills through interactive gameplay.

## 🚀 Features

### 🎯 Minigames
- **Parejas (Pairs)**: Memory matching game with educational content
- **Sílabas (Syllables)**: Syllable recognition and matching
- **Shared Animation System**: Reusable animations for achievements and completions

### 🔐 Authentication System
- **Firebase Integration**: Real authentication with email/password
- **Profile System**: User profiles with session persistence
- **Google Sign-in Ready**: OAuth setup for Google authentication
- **Optional Login**: Play without account or register to save progress

### 🎨 UI/UX
- **Responsive Design**: Works across different screen sizes
- **Spanish Interface**: Full Spanish localization
- **Modern UI**: Clean, child-friendly interface
- **Animation Feedback**: Visual feedback for user actions

## 📁 Project Structure

```
lectoemocion/
├── assets/                    # Game assets
│   ├── animales/             # Animal images
│   ├── audio/                # Sound files
│   ├── fondos/               # Background images
│   └── IMÁGENES SUELTAS/     # Misc images
├── scenes/                   # Godot scenes
│   ├── main_menu.tscn        # Main menu
│   ├── minigames/            # Minigame scenes
│   │   ├── parejas/          # Pairs game
│   │   └── silabas/          # Syllables game
│   └── shared/               # Shared components
│       ├── animations.tscn   # Animation system
│       ├── base_card.tscn    # Base card component
│       ├── lives.tscn        # Lives display
│       └── profile_dialog.tscn # Profile/login dialog
├── scripts/                  # GDScript files
│   ├── main_menu.gd
│   ├── minigames/            # Minigame logic
│   └── shared/               # Shared scripts
│       ├── animations.gd     # Animation manager
│       ├── firebase_auth.gd  # Firebase authentication
│       ├── firebase_config.gd # Firebase configuration
│       └── profile_dialog.gd # Profile dialog logic
└── shaders/                  # Custom shaders
```

## 🔥 Firebase Setup

### Current Status
- ✅ **Firebase Project**: `lectoemocion-game`
- ✅ **Email/Password Auth**: Working
- ✅ **Firestore Database**: Integrated for user profiles
- ✅ **Profile System**: Integrated with automatic profile creation
- ✅ **Session Persistence**: Across app restarts
- ✅ **Google Sign-in**: UI ready, browser-based OAuth

### Configuration
Your Firebase configuration is in `scripts/shared/firebase_config.gd`:

```gdscript
const CONFIG = {
    "apiKey": "AIzaSyDte23QszehKyx2pVPSdQCgpUBHn13bi48",
    "authDomain": "lectoemocion-game.firebaseapp.com",
    "projectId": "lectoemocion-game",
    "storageBucket": "lectoemocion-game.firebasestorage.app",
    "messagingSenderId": "718149941592",
    "appId": "1:718149941592:web:cc8b32d6d1dcb6155e8d2d",
    "measurementId": "G-7HLWEX89JK"
}
```

**Note:** You don't need a `.env` file for this setup. All configuration is handled directly in the GDScript files using HTTP REST API calls.

### Google Sign-in Setup
To complete Google Sign-in:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **lectoemocion-game**
3. Go to **Authentication** > **Sign-in method**
4. Click **Google** provider
5. Add **Authorized redirect URI**: `http://localhost:8080/auth/callback`
6. Copy the **Web client ID** (already configured: `718149941592-t6c2inq4k3o61upls5703no2ame7n69b.apps.googleusercontent.com`)
7. **Enable Google Sign-in** if not already enabled

### Testing Authentication
1. Run the project
2. Click "👤 Perfil" button
3. Register with:
   - Email: `test@lectoemocion.com`
   - Password: `123456`
   - Name: `Test User`
4. Login and see your profile

## 🎬 Animation System

### Types of Animations
1. **Small Completion** (`show_small_completion`):
   - For minor achievements
   - ~2 seconds duration
   - Customizable message and icon

2. **Game Completion** (`show_game_completion`):
   - For finishing minigames
   - Shows performance metrics
   - Star rating system
   - Longer duration with celebrations

### Usage in Minigames
```gdscript
# In your minigame script
@onready var animations = $Animations

# For small achievements
animations.show_small_completion("¡Bien hecho!", "star")

# For game completion
animations.show_game_completion(85.5, 12, 10)  # 85.5% accuracy, 12 correct, 10 total
```

### Reusability
- **Shared across all minigames**
- **Consistent visual feedback**
- **Easy to customize**
- **Sound support ready** (to be implemented)

## 🎮 Minigames

### Parejas (Pairs Game)
- **Location**: `scenes/minigames/parejas/`
- **Features**: Memory matching with educational content
- **Configurable**: Number of pairs per game
- **Tracking**: Attempts and accuracy

### Sílabas (Syllables Game)
- **Location**: `scenes/minigames/silabas/`
- **Features**: Syllable recognition and matching
- **Interactive**: Drag and drop mechanics
- **Progressive**: Increasing difficulty

### Shared Components
- **Base Card**: Common card component for all games
- **Lives System**: Health/attempts tracking
- **Animation Manager**: Centralized animation handling

## 🛠️ Technical Details

### Firebase Authentication
- **REST API**: Direct Firebase REST API integration
- **Security**: Secure token-based authentication
- **Error Handling**: User-friendly Spanish error messages
- **Persistence**: Session tokens with automatic refresh

### Godot 4 Features
- **Scene System**: Modular scene architecture
- **Autoload Singletons**: Global managers (Firebase, Game Manager)
- **Signal System**: Event-driven communication
- **Resource Management**: Efficient asset loading

### Code Organization
- **Separation of Concerns**: Clear separation between UI, logic, and data
- **Reusable Components**: Shared scenes and scripts
- **Consistent Naming**: Spanish naming for user-facing elements
- **Documentation**: Comprehensive code comments

## 🎯 Current Features

### ✅ Working
- Email/password authentication
- User registration and login
- Profile management
- Session persistence
- Animation system
- Minigame framework
- Main menu navigation

### 🔄 In Progress
- Google Sign-in (needs client ID)
- Sound integration for animations
- Additional minigames
- Progress tracking

### 📋 Planned
- User progress database
- Achievement system
- Leaderboards
- More minigames
- Offline mode improvements

## 🚀 Getting Started

### Prerequisites
- Godot 4.4 or later
- Firebase project (already configured)
- Internet connection for authentication

### Running the Project
1. Open the project in Godot
2. Set main scene to `scenes/main_menu.tscn`
3. Run the project (F5)
4. Test authentication with the profile button

### Development
1. **Adding new minigames**: Use the existing structure in `scenes/minigames/`
2. **Modifying animations**: Edit `scenes/shared/animations.tscn`
3. **Firebase changes**: Update `scripts/shared/firebase_config.gd`
4. **UI updates**: Follow the existing Spanish naming conventions

## 📱 Export Settings

### Platforms
- **Desktop**: Windows, macOS, Linux
- **Web**: HTML5 export ready
- **Mobile**: Android/iOS (with platform-specific OAuth)

### Firebase Considerations
- **Web**: JavaScript Firebase SDK integration
- **Desktop**: HTTP-based authentication (current)
- **Mobile**: Platform-specific OAuth flows

## 🤝 Contributing

### Code Style
- **Spanish**: User-facing text and variables
- **English**: Technical comments and documentation
- **Consistent**: Follow existing patterns
- **Documented**: Add comments for complex logic

### Adding Features
1. Create feature branch
2. Follow existing architecture
3. Test thoroughly
4. Update documentation
5. Submit pull request

## 📄 License

This project is part of an educational initiative. Please respect the educational nature of the content and assets.

## 🔧 Troubleshooting

### Common Issues

#### **"Operation not allowed" Error (400)**
**Problem**: `auth/operation-not-allowed` when trying to register
**Cause**: Email/Password authentication not enabled in Firebase Console
**Solution**:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **lectoemocion-game**
3. Go to **Authentication** > **Sign-in method**
4. Find **Email/Password** provider
5. **Enable** both toggles:
   - ✅ Email/Password
   - ✅ Email link (passwordless sign-in) - optional
6. Click **Save**

#### **Profile Dialog Not Fully Displayed**
**Problem**: Dialog appears cut off or too big for screen
**Solution**: Fixed with responsive design
- Added ScrollContainer for better content management
- Reduced dialog size: 350x400 (was 400x500)
- Added minimum size constraints
- Text wrapping for long emails/names

#### **Google Sign-in Issues**
**Problem**: Google OAuth not working properly
**Current Status**: 
- ✅ Opens browser with correct OAuth URL
- ✅ Uses proper Google Client ID
- ⚠️ Manual process (user completes in browser)
- 🔄 Full automation requires additional platform setup

#### **Parser Errors**
**Problem**: Scene files not loading
**Solution**: 
- Removed invalid SubResource references
- Fixed scene file syntax
- Updated node paths for new structure

### Debug Tips
- Use Godot's remote debugger
- Check Firebase Console for authentication logs
- Monitor network requests in development
- Test with different user accounts
- Verify Firebase Console settings match your code

### Firebase Console Checklist
- [ ] Email/Password provider enabled
- [ ] Google provider enabled (if using)
- [ ] Correct API key in configuration
- [ ] Domain whitelist configured (for web)
- [ ] User creation permissions enabled

## 📞 Support

For issues or questions:
1. Check existing documentation
2. Review Firebase Console logs
3. Test with minimal examples
4. Create detailed issue reports

---

**LectoEmoción** - Making learning fun through interactive gameplay! 🎮✨ 