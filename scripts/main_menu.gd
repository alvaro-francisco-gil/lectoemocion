extends Control

func _ready():
	$VBoxContainer/SilabasButton.pressed.connect(_on_silabas_button_pressed)
	$VBoxContainer/ParejasButton.pressed.connect(_on_parejas_button_pressed)
	$VBoxContainer/CartapumButton.pressed.connect(_on_cartapum_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	# Add cross-minigame hover and click effects to all buttons
	if GameManager:
		GameManager.add_hover_effect($VBoxContainer/SilabasButton)
		GameManager.add_hover_effect($VBoxContainer/ParejasButton)
		GameManager.add_hover_effect($VBoxContainer/CartapumButton)
		GameManager.add_hover_effect($VBoxContainer/QuitButton)

func _on_silabas_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/silabas/game.tscn")

func _on_parejas_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/parejas/parejas.tscn")

func _on_cartapum_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/cartapum/cartapum.tscn")

func _on_quit_button_pressed():
	get_tree().quit() 
