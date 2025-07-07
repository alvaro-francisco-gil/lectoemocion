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
# Client ID from Google Cloud Console > APIs & Services > Credentials
const GOOGLE_CLIENT_ID = "718149941592-t6c2inq4k3o61upls5703no2ame7n69b.apps.googleusercontent.com"

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