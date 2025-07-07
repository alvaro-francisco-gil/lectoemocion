extends Node

# Firebase Auth Manager
# Handles user authentication and profile management using Firebase REST API

signal user_logged_in(user_data)
signal user_logged_out
signal auth_error(error_message)

var current_user = null
var is_logged_in = false
var http_request: HTTPRequest

# Firebase REST API endpoints
const AUTH_REGISTER_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp"
const AUTH_LOGIN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
const AUTH_REFRESH_URL = "https://identitytoolkit.googleapis.com/v1/token"

func _ready():
	print("Firebase Auth Manager initialized")
	
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	# Check if user was previously logged in
	load_user_session()

func login_with_email(email: String, password: String):
	"""
	Attempt to log in with email and password using Firebase Auth REST API
	"""
	print("Attempting Firebase login with email: ", email)
	
	var url = AUTH_LOGIN_URL + "?key=" + FirebaseConfig.get_api_key()
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		emit_signal("auth_error", "Error al conectar con Firebase")

func register_with_email(email: String, password: String, display_name: String = ""):
	"""
	Register a new user with email and password using Firebase Auth REST API
	"""
	print("Attempting Firebase registration with email: ", email)
	
	if password.length() < 6:
		emit_signal("auth_error", "La contraseña debe tener al menos 6 caracteres")
		return
	
	var url = AUTH_REGISTER_URL + "?key=" + FirebaseConfig.get_api_key()
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		emit_signal("auth_error", "Error al conectar con Firebase")

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""
	Handle HTTP responses from Firebase
	"""
	print("Firebase response: ", response_code)
	
	if response_code == 200:
		# Parse successful response
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			_handle_successful_auth(response_data)
		else:
			emit_signal("auth_error", "Error al procesar respuesta de Firebase")
	else:
		# Handle error response
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK and "error" in json.data:
			var error_message = _get_friendly_error_message(json.data.error.message)
			emit_signal("auth_error", error_message)
		else:
			emit_signal("auth_error", "Error de autenticación")

func _handle_successful_auth(response_data: Dictionary):
	"""
	Handle successful authentication response from Firebase
	"""
	var user_data = {
		"uid": response_data.get("localId", ""),
		"email": response_data.get("email", ""),
		"display_name": response_data.get("displayName", response_data.get("email", "").split("@")[0]),
		"id_token": response_data.get("idToken", ""),
		"refresh_token": response_data.get("refreshToken", "")
	}
	
	current_user = user_data
	is_logged_in = true
	save_user_session()
	
	emit_signal("user_logged_in", user_data)
	print("Firebase login successful for: ", user_data.email)

func _get_friendly_error_message(error_message: String) -> String:
	"""
	Convert Firebase error messages to user-friendly Spanish messages
	"""
	match error_message:
		"EMAIL_EXISTS":
			return "Este email ya está registrado"
		"OPERATION_NOT_ALLOWED":
			return "Operación no permitida"
		"TOO_MANY_ATTEMPTS_TRY_LATER":
			return "Demasiados intentos. Intenta más tarde"
		"EMAIL_NOT_FOUND":
			return "Email no encontrado"
		"INVALID_PASSWORD":
			return "Contraseña incorrecta"
		"USER_DISABLED":
			return "Usuario deshabilitado"
		"INVALID_EMAIL":
			return "Email inválido"
		"WEAK_PASSWORD":
			return "Contraseña muy débil"
		_:
			return "Error de autenticación: " + error_message

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

# Future functions for Firebase plugin integration:
func login_with_google():
	"""
	Log in with Google (requires Firebase plugin)
	"""
	emit_signal("auth_error", "Login con Google requiere el plugin de Firebase")

func reset_password(email: String):
	"""
	Send password reset email using Firebase REST API
	"""
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=" + FirebaseConfig.get_api_key()
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"requestType": "PASSWORD_RESET",
		"email": email
	})
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		emit_signal("auth_error", "Error al enviar email de recuperación")

func update_profile(display_name: String):
	"""
	Update user profile (requires authentication token)
	"""
	if not current_user or not current_user.has("id_token"):
		emit_signal("auth_error", "Debes estar autenticado para actualizar perfil")
		return
	
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:update?key=" + FirebaseConfig.get_api_key()
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"idToken": current_user.id_token,
		"displayName": display_name,
		"returnSecureToken": true
	})
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		emit_signal("auth_error", "Error al actualizar perfil") 