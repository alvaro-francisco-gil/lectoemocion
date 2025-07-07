extends Node

# Firebase Auth Manager
# Handles user authentication and profile management using Firebase REST API

signal user_logged_in(user_data)
signal user_logged_out
signal auth_error(error_message)
signal user_profile_created(profile_data)
signal user_profile_updated(profile_data)
signal firestore_error(error_message)

var current_user = null
var is_logged_in = false
var http_request: HTTPRequest
var last_request_type = ""  # Track what type of request we're making

# OAuth server variables
var oauth_server: TCPServer
var oauth_thread: Thread
var oauth_running = false

# Firebase REST API endpoints
const AUTH_REGISTER_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp"
const AUTH_LOGIN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
const AUTH_REFRESH_URL = "https://identitytoolkit.googleapis.com/v1/token"
const AUTH_GOOGLE_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp"

# Firestore REST API endpoints
var firestore_base_url: String

func _ready():
	print("Firebase Auth Manager initialized")
	
	# Initialize Firestore URL
	firestore_base_url = "https://firestore.googleapis.com/v1/projects/" + FirebaseConfig.get_project_id() + "/databases/(default)/documents/"
	
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	# Load saved user session
	load_user_session()

func login_with_email(email: String, password: String):
	"""Login with email and password"""
	print("Attempting email login for: ", email)
	
	var body = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)
	var url = AUTH_LOGIN_URL + "?key=" + FirebaseConfig.get_api_key()
	
	last_request_type = "auth_login"
	var result = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if result != OK:
		auth_error.emit("Error al realizar la petición HTTP: " + str(result))

func register_with_email(email: String, password: String, display_name: String = ""):
	"""Register new user with email and password"""
	print("Attempting registration for: ", email)
	
	var body = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	
	if display_name != "":
		body["displayName"] = display_name
	
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)
	var url = AUTH_REGISTER_URL + "?key=" + FirebaseConfig.get_api_key()
	
	last_request_type = "auth_register"
	var result = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if result != OK:
		auth_error.emit("Error al realizar la petición HTTP: " + str(result))

func login_with_google():
	"""Login with Google OAuth"""
	print("Attempting Google Sign-in")
	
	# Start local HTTP server to handle OAuth callback
	_start_oauth_server()
	
	# Create Google OAuth URL
	var google_auth_url = "https://accounts.google.com/oauth/v2/auth"
	var redirect_uri = "http://localhost:8080/auth/callback"
	var params = {
		"client_id": FirebaseConfig.get_google_client_id(),
		"redirect_uri": redirect_uri,
		"response_type": "code",
		"scope": "openid email profile",
		"state": "google_signin"
	}
	
	var url_params = []
	for key in params:
		url_params.append(key + "=" + params[key].uri_encode())
	
	var full_url = google_auth_url + "?" + "&".join(url_params)
	
	print("Opening Google OAuth URL: ", full_url)
	OS.shell_open(full_url)
	
	# Show user feedback
	auth_error.emit("Google Sign-in abierto en el navegador. Completando autenticación...")

func _start_oauth_server():
	"""Start local HTTP server to handle OAuth callback"""
	if oauth_running:
		return
	
	oauth_server = TCPServer.new()
	var result = oauth_server.listen(8080, "127.0.0.1")
	
	if result == OK:
		oauth_running = true
		print("OAuth server started on port 8080")
		# Start checking for connections
		_check_oauth_connections()
	else:
		print("Failed to start OAuth server: ", result)
		auth_error.emit("Error al iniciar servidor local para Google Sign-in")

func _check_oauth_connections():
	"""Check for OAuth callback connections"""
	if not oauth_running or not oauth_server:
		return
	
	# Check for new connections
	if oauth_server.is_connection_available():
		var client = oauth_server.take_connection()
		_handle_oauth_request(client)
	
	# Continue checking if still running
	if oauth_running:
		# Use a timer to check again
		get_tree().create_timer(0.1).timeout.connect(_check_oauth_connections)

func _handle_oauth_request(client: StreamPeerTCP):
	"""Handle OAuth callback request"""
	print("Received OAuth callback request")
	
	# Read the HTTP request
	var request_data = ""
	while client.get_available_bytes() > 0:
		var chunk = client.get_string(client.get_available_bytes())
		request_data += chunk
	
	print("OAuth request data: ", request_data)
	
	# Parse the request to get the authorization code
	var auth_code = _extract_auth_code(request_data)
	
	# Send response to browser
	var response = "HTTP/1.1 200 OK\r\n"
	response += "Content-Type: text/html\r\n"
	response += "Connection: close\r\n\r\n"
	response += "<html><body><h1>¡Autenticación exitosa!</h1><p>Puedes cerrar esta ventana y volver al juego.</p></body></html>"
	
	client.put_data(response.to_utf8_buffer())
	client.disconnect_from_host()
	
	# Stop the server
	_stop_oauth_server()
	
	# Exchange the code for tokens
	if auth_code != "":
		exchange_google_code_for_token(auth_code)
	else:
		auth_error.emit("No se pudo obtener el código de autorización de Google")

func _extract_auth_code(request_data: String) -> String:
	"""Extract authorization code from OAuth callback request"""
	var lines = request_data.split("\n")
	if lines.size() > 0:
		var first_line = lines[0]
		if first_line.contains("code="):
			var params = first_line.split("?")
			if params.size() > 1:
				var query_params = params[1].split("&")
				for param in query_params:
					if param.begins_with("code="):
						return param.split("=")[1].split(" ")[0]  # Remove HTTP/1.1 part
	return ""

func _stop_oauth_server():
	"""Stop the OAuth server"""
	oauth_running = false
	if oauth_server:
		oauth_server.stop()
		oauth_server = null
	print("OAuth server stopped")

func exchange_google_code_for_token(auth_code: String):
	"""Exchange Google authorization code for Firebase token"""
	print("Exchanging Google auth code for token: ", auth_code)
	
	# First, exchange the code for Google tokens
	var token_url = "https://oauth2.googleapis.com/token"
	var body = {
		"code": auth_code,
		"client_id": FirebaseConfig.get_google_client_id(),
		"client_secret": "",  # For public clients, this might be empty
		"redirect_uri": "http://localhost:8080/auth/callback",
		"grant_type": "authorization_code"
	}
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var form_data = ""
	for key in body:
		if form_data != "":
			form_data += "&"
		form_data += key + "=" + str(body[key]).uri_encode()
	
	last_request_type = "google_token_exchange"
	var result = http_request.request(token_url, headers, HTTPClient.METHOD_POST, form_data)
	
	if result != OK:
		auth_error.emit("Error al intercambiar código de Google: " + str(result))

func logout():
	"""Logout current user"""
	print("Logging out user")
	current_user = null
	is_logged_in = false
	clear_user_session()
	user_logged_out.emit()

func get_current_user():
	"""Get current user data"""
	return current_user

func is_user_logged_in() -> bool:
	"""Check if user is logged in"""
	return is_logged_in and current_user != null

func create_user_profile(user_data: Dictionary):
	"""Create a new user profile in Firestore"""
	if not current_user or not current_user.has("id_token"):
		firestore_error.emit("Debes estar autenticado para crear perfil")
		return
	
	print("Creating user profile in Firestore...")
	
	var profile_data = {
		"fields": {
			"uid": {"stringValue": user_data.uid},
			"email": {"stringValue": user_data.email},
			"displayName": {"stringValue": user_data.display_name},
			"createdAt": {"timestampValue": _get_iso_timestamp()},
			"lastLoginAt": {"timestampValue": _get_iso_timestamp()},
			"gamesPlayed": {"integerValue": "0"},
			"totalScore": {"integerValue": "0"},
			"level": {"integerValue": "1"}
		}
	}
	
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + current_user.id_token]
	var json_body = JSON.stringify(profile_data)
	var url = firestore_base_url + "users/" + user_data.uid
	
	last_request_type = "firestore_create_profile"
	var result = http_request.request(url, headers, HTTPClient.METHOD_PATCH, json_body)
	
	if result != OK:
		firestore_error.emit("Error al crear perfil: " + str(result))

func update_user_profile(updates: Dictionary):
	"""Update user profile in Firestore"""
	if not current_user or not current_user.has("id_token"):
		firestore_error.emit("Debes estar autenticado para actualizar perfil")
		return
	
	print("Updating user profile in Firestore...")
	
	var profile_data = {
		"fields": {}
	}
	
	# Convert updates to Firestore format
	for key in updates:
		var value = updates[key]
		if value is String:
			# Check if this is a timestamp field
			if key.ends_with("At") or key.ends_with("Time"):
				profile_data.fields[key] = {"timestampValue": value}
			else:
				profile_data.fields[key] = {"stringValue": value}
		elif value is int:
			profile_data.fields[key] = {"integerValue": str(value)}
		elif value is bool:
			profile_data.fields[key] = {"booleanValue": value}
	
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + current_user.id_token]
	var json_body = JSON.stringify(profile_data)
	var url = firestore_base_url + "users/" + current_user.uid + "?updateMask.fieldPaths=" + "&updateMask.fieldPaths=".join(updates.keys())
	
	last_request_type = "firestore_update_profile"
	var result = http_request.request(url, headers, HTTPClient.METHOD_PATCH, json_body)
	
	if result != OK:
		firestore_error.emit("Error al actualizar perfil: " + str(result))

func update_game_stats(game_name: String, score: int, completed: bool = true):
	"""Helper function to update game statistics"""
	if not is_user_logged_in():
		print("User not logged in, skipping stats update")
		return
	
	print("Updating game stats for: ", game_name)
	
	var updates = {
		"lastGamePlayed": game_name,
		"lastPlayedAt": Time.get_datetime_string_from_system(),
		"gamesPlayed": "INCREMENT",  # We'll need to handle this specially
		"totalScore": "INCREMENT_BY_" + str(score)  # We'll need to handle this specially
	}
	
	# For now, let's just update the basic fields
	var simple_updates = {
		"lastGamePlayed": game_name,
		"lastPlayedAt": _get_iso_timestamp()
	}
	
	update_user_profile(simple_updates)

func get_user_profile():
	"""Get user profile from Firestore"""
	if not current_user or not current_user.has("id_token"):
		firestore_error.emit("Debes estar autenticado para obtener perfil")
		return
	
	print("Getting user profile from Firestore...")
	
	var headers = ["Authorization: Bearer " + current_user.id_token]
	var url = firestore_base_url + "users/" + current_user.uid
	
	last_request_type = "firestore_get_profile"
	var result = http_request.request(url, headers, HTTPClient.METHOD_GET)
	
	if result != OK:
		firestore_error.emit("Error al obtener perfil: " + str(result))

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle HTTP request completion"""
	print("HTTP Request completed. Response code: ", response_code, " Request type: ", last_request_type)
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			
			# Handle different types of responses
			match last_request_type:
				"auth_login", "auth_register":
					_handle_auth_success(response_data)
				"firestore_create_profile":
					_handle_firestore_profile_created(response_data)
				"firestore_update_profile":
					_handle_firestore_profile_updated(response_data)
				"firestore_get_profile":
					_handle_firestore_profile_retrieved(response_data)
				"google_token_exchange":
					_handle_google_token_response(response_data)
				"firebase_google_auth":
					_handle_auth_success(response_data)
				_:
					print("Unknown request type: ", last_request_type)
		else:
			print("JSON parse error: ", json.get_error_message())
			if last_request_type.begins_with("auth_"):
				auth_error.emit("Error al procesar la respuesta del servidor")
			else:
				firestore_error.emit("Error al procesar la respuesta del servidor")
	else:
		if last_request_type.begins_with("auth_"):
			_handle_auth_error(response_code, body)
		else:
			_handle_firestore_error(response_code, body)

func _handle_auth_success(data: Dictionary):
	"""Handle successful authentication"""
	print("Authentication successful")
	
	# Create user object
	current_user = {
		"uid": data.get("localId", ""),
		"email": data.get("email", ""),
		"display_name": data.get("displayName", data.get("email", "Usuario")),
		"id_token": data.get("idToken", ""),
		"refresh_token": data.get("refreshToken", ""),
		"expires_in": data.get("expiresIn", "3600")
	}
	
	is_logged_in = true
	save_user_session()
	
	# Create or update user profile in Firestore
	create_user_profile(current_user)
	
	user_logged_in.emit(current_user)

func _handle_auth_error(response_code: int, body: PackedByteArray):
	"""Handle authentication errors"""
	var error_message = "Error de autenticación"
	var body_text = body.get_string_from_utf8()
	
	if body.size() > 0:
		var json = JSON.new()
		var parse_result = json.parse(body_text)
		
		if parse_result == OK:
			var error_data = json.data
			var error_code = error_data.get("error", {}).get("message", "")
			error_message = _get_user_friendly_error(error_code)
		else:
			error_message = "Error de conexión (código: " + str(response_code) + ")"
	
	print("Authentication error: ", error_message)
	auth_error.emit(error_message)

func _handle_firestore_error(response_code: int, body: PackedByteArray):
	"""Handle Firestore errors"""
	var error_message = "Error de Firestore"
	var body_text = body.get_string_from_utf8()
	
	print("Firestore error body: ", body_text)
	
	if body.size() > 0:
		var json = JSON.new()
		var parse_result = json.parse(body_text)
		
		if parse_result == OK:
			var error_data = json.data
			var error_code = error_data.get("error", {}).get("status", "")
			var error_message_detail = error_data.get("error", {}).get("message", "")
			print("Firestore error code: ", error_code)
			print("Firestore error message: ", error_message_detail)
			error_message = _get_firestore_error_message(error_code, response_code)
		else:
			error_message = "Error de conexión con Firestore (código: " + str(response_code) + ")"
	
	print("Firestore error: ", error_message)
	firestore_error.emit(error_message)

func _handle_firestore_profile_created(data: Dictionary):
	"""Handle successful profile creation"""
	print("User profile created successfully")
	user_profile_created.emit(data)

func _handle_firestore_profile_updated(data: Dictionary):
	"""Handle successful profile update"""
	print("User profile updated successfully")
	user_profile_updated.emit(data)

func _handle_firestore_profile_retrieved(data: Dictionary):
	"""Handle successful profile retrieval"""
	print("User profile retrieved successfully")
	# Convert Firestore format to simple dictionary
	var profile = {}
	if data.has("fields"):
		for key in data.fields:
			var field = data.fields[key]
			if field.has("stringValue"):
				profile[key] = field.stringValue
			elif field.has("integerValue"):
				profile[key] = int(field.integerValue)
			elif field.has("booleanValue"):
				profile[key] = field.booleanValue
			elif field.has("timestampValue"):
				profile[key] = field.timestampValue
	
	user_profile_updated.emit(profile)

func _handle_google_token_response(data: Dictionary):
	"""Handle Google token exchange response"""
	print("Google token response received")
	
	if data.has("id_token"):
		var id_token = data.id_token
		print("Received Google ID token")
		
		# Now use this token to authenticate with Firebase
		_authenticate_with_firebase_using_google_token(id_token)
	else:
		print("No ID token in Google response: ", data)
		auth_error.emit("Error al obtener token de Google")

func _authenticate_with_firebase_using_google_token(id_token: String):
	"""Authenticate with Firebase using Google ID token"""
	print("Authenticating with Firebase using Google token")
	
	var body = {
		"requestUri": "http://localhost:8080/auth/callback",
		"postBody": "id_token=" + id_token + "&providerId=google.com",
		"returnSecureToken": true,
		"returnIdpCredential": true
	}
	
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)
	var url = AUTH_GOOGLE_URL + "?key=" + FirebaseConfig.get_api_key()
	
	last_request_type = "firebase_google_auth"
	var result = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if result != OK:
		auth_error.emit("Error al autenticar con Firebase usando Google: " + str(result))

func _get_firestore_error_message(error_code: String, response_code: int) -> String:
	"""Convert Firestore error codes to user-friendly messages"""
	match error_code:
		"PERMISSION_DENIED":
			return "Sin permisos para acceder a los datos del perfil."
		"NOT_FOUND":
			return "Perfil de usuario no encontrado."
		"ALREADY_EXISTS":
			return "El perfil ya existe."
		"UNAUTHENTICATED":
			return "Debes estar autenticado para acceder al perfil."
		"INVALID_ARGUMENT":
			return "Error de formato de datos. Verifica la configuración."
		_:
			return "Error de Firestore (código: " + str(response_code) + ")"

func _get_iso_timestamp() -> String:
	"""Get current timestamp in ISO format for Firestore"""
	var datetime = Time.get_datetime_dict_from_system()
	var iso_string = "%04d-%02d-%02dT%02d:%02d:%02dZ" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second
	]
	return iso_string

func _get_user_friendly_error(error_code: String) -> String:
	"""Convert Firebase error codes to user-friendly Spanish messages"""
	match error_code:
		"EMAIL_NOT_FOUND":
			return "Email no encontrado. ¿Necesitas registrarte?"
		"INVALID_PASSWORD":
			return "Contraseña incorrecta. Inténtalo de nuevo."
		"USER_DISABLED":
			return "Esta cuenta ha sido deshabilitada."
		"EMAIL_EXISTS":
			return "Este email ya está registrado. ¿Quieres iniciar sesión?"
		"OPERATION_NOT_ALLOWED":
			return "Operación no permitida. Verifica que Email/Password esté habilitado en Firebase Console."
		"TOO_MANY_ATTEMPTS_TRY_LATER":
			return "Demasiados intentos. Inténtalo más tarde."
		"WEAK_PASSWORD":
			return "La contraseña es muy débil. Usa al menos 6 caracteres."
		"INVALID_EMAIL":
			return "Email no válido. Verifica el formato."
		"INVALID_API_KEY":
			return "Clave API inválida. Verifica la configuración de Firebase."
		"API_KEY_NOT_VALID":
			return "Clave API no válida. Verifica la configuración de Firebase."
		_:
			return "Error de conexión (" + error_code + "). Verifica tu internet."

func save_user_session():
	"""Save user session to local storage"""
	if current_user:
		var config = ConfigFile.new()
		config.set_value("user", "uid", current_user.uid)
		config.set_value("user", "email", current_user.email)
		config.set_value("user", "display_name", current_user.display_name)
		config.set_value("user", "id_token", current_user.id_token)
		config.set_value("user", "refresh_token", current_user.refresh_token)
		config.save("user://user_session.cfg")

func load_user_session():
	"""Load user session from local storage"""
	var config = ConfigFile.new()
	if config.load("user://user_session.cfg") == OK:
		current_user = {
			"uid": config.get_value("user", "uid", ""),
			"email": config.get_value("user", "email", ""),
			"display_name": config.get_value("user", "display_name", "Usuario"),
			"id_token": config.get_value("user", "id_token", ""),
			"refresh_token": config.get_value("user", "refresh_token", "")
		}
		
		if current_user.uid != "":
			is_logged_in = true
			print("User session loaded: ", current_user.email)
		else:
			current_user = null

func clear_user_session():
	"""Clear saved user session"""
	var config = ConfigFile.new()
	if config.load("user://user_session.cfg") == OK:
		config.clear()
		config.save("user://user_session.cfg")

# Future functions for Firebase plugin integration:
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
