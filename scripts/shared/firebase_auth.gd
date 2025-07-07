extends Node

# Firebase Auth Manager
# Handles user authentication and profile management

signal user_logged_in(user_data)
signal user_logged_out
signal auth_error(error_message)

var current_user = null
var is_logged_in = false

# Mock Firebase functionality for now (will be replaced with real Firebase)
var mock_users = {
	"test@example.com": {
		"password": "123456",
		"display_name": "Usuario Test",
		"uid": "test_user_123"
	}
}

func _ready():
	print("Firebase Auth Manager initialized")
	# Check if user was previously logged in (from saved data)
	load_user_session()

func login_with_email(email: String, password: String):
	"""
	Attempt to log in with email and password
	"""
	print("Attempting login with email: ", email)
	
	# Mock authentication (replace with real Firebase later)
	if email in mock_users and mock_users[email]["password"] == password:
		var user_data = {
			"uid": mock_users[email]["uid"],
			"email": email,
			"display_name": mock_users[email]["display_name"]
		}
		
		current_user = user_data
		is_logged_in = true
		save_user_session()
		
		emit_signal("user_logged_in", user_data)
		print("Login successful for: ", email)
	else:
		emit_signal("auth_error", "Email o contraseña incorrectos")
		print("Login failed for: ", email)

func register_with_email(email: String, password: String, display_name: String = ""):
	"""
	Register a new user with email and password
	"""
	print("Attempting registration with email: ", email)
	
	# Mock registration (replace with real Firebase later)
	if email in mock_users:
		emit_signal("auth_error", "Este email ya está registrado")
		return
	
	if password.length() < 6:
		emit_signal("auth_error", "La contraseña debe tener al menos 6 caracteres")
		return
	
	# Create new user
	var uid = "user_" + str(randi())
	mock_users[email] = {
		"password": password,
		"display_name": display_name if display_name != "" else email.split("@")[0],
		"uid": uid
	}
	
	# Auto-login after registration
	login_with_email(email, password)

func logout():
	"""
	Log out the current user
	"""
	print("Logging out user: ", current_user.email if current_user else "None")
	current_user = null
	is_logged_in = false
	clear_user_session()
	emit_signal("user_logged_out")

func get_current_user():
	"""
	Get the currently logged in user data
	"""
	return current_user

func is_user_logged_in():
	"""
	Check if a user is currently logged in
	"""
	return is_logged_in

func save_user_session():
	"""
	Save user session to persistent storage
	"""
	if current_user:
		var file = FileAccess.open("user://user_session.dat", FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(current_user))
			file.close()

func load_user_session():
	"""
	Load user session from persistent storage
	"""
	var file = FileAccess.open("user://user_session.dat", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			current_user = json.data
			is_logged_in = true
			print("User session loaded: ", current_user.email)

func clear_user_session():
	"""
	Clear saved user session
	"""
	var file = FileAccess.open("user://user_session.dat", FileAccess.WRITE)
	if file:
		file.store_string("")
		file.close()

# Future functions for real Firebase integration:
func login_with_google():
	"""
	Log in with Google (to be implemented with Firebase)
	"""
	pass

func reset_password(email: String):
	"""
	Send password reset email (to be implemented with Firebase)
	"""
	pass

func update_profile(display_name: String):
	"""
	Update user profile (to be implemented with Firebase)
	"""
	pass 