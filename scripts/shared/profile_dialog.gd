extends AcceptDialog

# Profile Dialog Script
# Handles login, registration, and profile display

@onready var profile_view = $VBoxContainer/ProfileView
@onready var login_view = $VBoxContainer/LoginView
@onready var error_label = $VBoxContainer/ErrorLabel

# Profile view nodes
@onready var welcome_label = $VBoxContainer/ProfileView/WelcomeLabel
@onready var display_name_label = $VBoxContainer/ProfileView/UserInfo/DisplayNameLabel
@onready var email_label = $VBoxContainer/ProfileView/UserInfo/EmailLabel
@onready var logout_button = $VBoxContainer/ProfileView/LogoutButton

# Login form nodes
@onready var google_signin_button = $VBoxContainer/LoginView/GoogleSignInButton
@onready var email_input = $VBoxContainer/LoginView/LoginForm/EmailInput
@onready var password_input = $VBoxContainer/LoginView/LoginForm/PasswordInput
@onready var login_button = $VBoxContainer/LoginView/LoginForm/LoginButton

# Register form nodes
@onready var reg_email_input = $VBoxContainer/LoginView/RegisterForm/RegEmailInput
@onready var reg_password_input = $VBoxContainer/LoginView/RegisterForm/RegPasswordInput
@onready var reg_name_input = $VBoxContainer/LoginView/RegisterForm/RegNameInput
@onready var register_button = $VBoxContainer/LoginView/RegisterForm/RegisterButton

var firebase_auth: Node

func _ready():
	# Get Firebase Auth instance
	firebase_auth = get_node("/root/FirebaseAuth")
	
	# Connect signals
	firebase_auth.user_logged_in.connect(_on_user_logged_in)
	firebase_auth.user_logged_out.connect(_on_user_logged_out)
	firebase_auth.auth_error.connect(_on_auth_error)
	
	# Connect button signals
	google_signin_button.pressed.connect(_on_google_signin_button_pressed)
	login_button.pressed.connect(_on_login_button_pressed)
	register_button.pressed.connect(_on_register_button_pressed)
	logout_button.pressed.connect(_on_logout_button_pressed)
	
	# Connect Enter key for login
	email_input.text_submitted.connect(_on_login_submit)
	password_input.text_submitted.connect(_on_login_submit)
	
	# Connect Enter key for registration
	reg_email_input.text_submitted.connect(_on_register_submit)
	reg_password_input.text_submitted.connect(_on_register_submit)
	reg_name_input.text_submitted.connect(_on_register_submit)
	
	# Update UI based on current auth state
	update_ui()

func _on_google_signin_button_pressed():
	"""Handle Google Sign-in button press"""
	# For now, show that Google Sign-in requires additional setup
	show_error("Google Sign-in requiere configuración adicional. Usa email/contraseña por ahora.")
	
	# TODO: Implement Google OAuth flow
	# This would require:
	# 1. Opening a web browser with Google OAuth URL
	# 2. Handling the redirect callback
	# 3. Exchanging the authorization code for tokens
	# 4. Using the ID token with Firebase

func _on_login_submit(text: String = ""):
	"""Handle Enter key press in login form"""
	_on_login_button_pressed()

func _on_register_submit(text: String = ""):
	"""Handle Enter key press in register form"""
	_on_register_button_pressed()

func update_ui():
	"""Update the UI based on authentication state"""
	clear_error()
	
	if firebase_auth.is_user_logged_in():
		show_profile_view()
	else:
		show_login_view()

func show_profile_view():
	"""Show the profile view for logged-in users"""
	profile_view.visible = true
	login_view.visible = false
	
	var user = firebase_auth.get_current_user()
	if user:
		welcome_label.text = "¡Bienvenido, " + user.display_name + "!"
		display_name_label.text = "Nombre: " + user.display_name
		email_label.text = "Email: " + user.email
		title = "Perfil de " + user.display_name

func show_login_view():
	"""Show the login/register view for non-authenticated users"""
	profile_view.visible = false
	login_view.visible = true
	title = "Iniciar Sesión"
	
	# Clear input fields
	email_input.text = ""
	password_input.text = ""
	reg_email_input.text = ""
	reg_password_input.text = ""
	reg_name_input.text = ""

func _on_login_button_pressed():
	"""Handle login button press"""
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email == "" or password == "":
		show_error("Por favor, completa todos los campos")
		return
	
	if not is_valid_email(email):
		show_error("Por favor, ingresa un email válido")
		return
	
	firebase_auth.login_with_email(email, password)

func _on_register_button_pressed():
	"""Handle register button press"""
	var email = reg_email_input.text.strip_edges()
	var password = reg_password_input.text
	var display_name = reg_name_input.text.strip_edges()
	
	if email == "" or password == "":
		show_error("Por favor, completa email y contraseña")
		return
	
	if not is_valid_email(email):
		show_error("Por favor, ingresa un email válido")
		return
	
	if password.length() < 6:
		show_error("La contraseña debe tener al menos 6 caracteres")
		return
	
	firebase_auth.register_with_email(email, password, display_name)

func _on_logout_button_pressed():
	"""Handle logout button press"""
	firebase_auth.logout()

func _on_user_logged_in(user_data):
	"""Handle successful login"""
	print("User logged in: ", user_data.email)
	update_ui()
	show_success("¡Bienvenido, " + user_data.display_name + "!")

func _on_user_logged_out():
	"""Handle successful logout"""
	print("User logged out")
	update_ui()
	show_success("Sesión cerrada correctamente")

func _on_auth_error(error_message: String):
	"""Handle authentication errors"""
	show_error(error_message)

func show_error(message: String):
	"""Display error message"""
	error_label.text = "❌ " + message
	error_label.modulate = Color(1, 0.3, 0.3, 1)

func show_success(message: String):
	"""Display success message"""
	error_label.text = "✅ " + message
	error_label.modulate = Color(0.3, 1, 0.3, 1)
	
	# Clear success message after 3 seconds
	await get_tree().create_timer(3.0).timeout
	clear_error()

func clear_error():
	"""Clear error/success message"""
	error_label.text = ""

func is_valid_email(email: String) -> bool:
	"""Basic email validation"""
	return email.contains("@") and email.contains(".") and email.length() > 5

func _on_about_to_popup():
	"""Called when dialog is about to be shown"""
	update_ui()
	
	# Focus on email input if not logged in
	if not firebase_auth.is_user_logged_in():
		email_input.grab_focus() 