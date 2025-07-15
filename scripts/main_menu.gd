extends Control

# Profile system
const ProfileDialogScene = preload("res://scenes/shared/profile_dialog.tscn")
var profile_dialog: AcceptDialog
var firebase_auth: Node

@onready var profile_button = $ProfileButton

func _ready():
	# Get Firebase Auth instance
	firebase_auth = get_node("/root/FirebaseAuth")
	
	# Connect game buttons
	$VBoxContainer/SilabasButton.pressed.connect(_on_silabas_button_pressed)
	$VBoxContainer/ParejasButton.pressed.connect(_on_parejas_button_pressed)
	$VBoxContainer/CartapumButton.pressed.connect(_on_cartapum_button_pressed)
	$VBoxContainer/InicialesButton.pressed.connect(_on_iniciales_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	# Connect profile button
	profile_button.pressed.connect(_on_profile_button_pressed)
	
	# Connect auth signals
	firebase_auth.user_logged_in.connect(_on_user_logged_in)
	firebase_auth.user_logged_out.connect(_on_user_logged_out)
	
	# Add cross-minigame hover and click effects to all buttons
	if GameManager:
		GameManager.add_hover_effect($VBoxContainer/SilabasButton)
		GameManager.add_hover_effect($VBoxContainer/ParejasButton)
		GameManager.add_hover_effect($VBoxContainer/CartapumButton)
		GameManager.add_hover_effect($VBoxContainer/InicialesButton)
		GameManager.add_hover_effect($VBoxContainer/QuitButton)
		GameManager.add_hover_effect(profile_button)
	
	# Update profile button text based on auth state
	update_profile_button()

func update_profile_button():
	"""Update the profile button text based on authentication state"""
	if firebase_auth.is_user_logged_in():
		var user = firebase_auth.get_current_user()
		if user:
			profile_button.text = "👤 " + user.display_name
			profile_button.tooltip_text = "Ver perfil de " + user.display_name
	else:
		profile_button.text = "👤 Perfil"
		profile_button.tooltip_text = "Iniciar sesión o registrarse"

func _on_profile_button_pressed():
	"""Handle profile button press"""
	if not profile_dialog:
		profile_dialog = ProfileDialogScene.instantiate()
		add_child(profile_dialog)
	
	profile_dialog.popup_centered()

func _on_user_logged_in(user_data):
	"""Handle user login"""
	print("User logged in from main menu: ", user_data.display_name)
	update_profile_button()

func _on_user_logged_out():
	"""Handle user logout"""
	print("User logged out from main menu")
	update_profile_button()

func _on_silabas_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/silabas/silabas.tscn")

func _on_parejas_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/parejas/parejas.tscn")

func _on_cartapum_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/cartapum/cartapum.tscn")

func _on_iniciales_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/iniciales/iniciales.tscn")

func _on_quit_button_pressed():
	get_tree().quit() 
