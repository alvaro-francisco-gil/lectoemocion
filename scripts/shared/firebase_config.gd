extends RefCounted

# Firebase Configuration for LectoEmocion Game
# This contains the Firebase project configuration

class_name FirebaseConfig

const CONFIG = {
	"apiKey": "AIzaSyDte23QszehKyx2pVPSdQCgpUBHn13bi48",
	"authDomain": "lectoemocion-game.firebaseapp.com",
	"databaseURL": "https://lectoemocion-game-default-rtdb.firebaseio.com/",
	"projectId": "lectoemocion-game",
	"storageBucket": "lectoemocion-game.firebasestorage.app",
	"messagingSenderId": "718149941592",
	"appId": "1:718149941592:web:cc8b32d6d1dcb6155e8d2d",
	"measurementId": "G-7HLWEX89JK"
}

# Google OAuth configuration
# To get your Google Client ID:
# 1. Go to Firebase Console > Authentication > Sign-in method
# 2. Click on Google provider
# 3. Copy the "Web client ID" (not the Web client secret)
const GOOGLE_CLIENT_ID = "718149941592-YOUR_CLIENT_ID.apps.googleusercontent.com"

# For future Firebase plugin integration
static func get_config() -> Dictionary:
	return CONFIG

static func get_api_key() -> String:
	return CONFIG["apiKey"]

static func get_auth_domain() -> String:
	return CONFIG["authDomain"]

static func get_database_url() -> String:
	return CONFIG["databaseURL"]

static func get_project_id() -> String:
	return CONFIG["projectId"]

static func get_google_client_id() -> String:
	return GOOGLE_CLIENT_ID 