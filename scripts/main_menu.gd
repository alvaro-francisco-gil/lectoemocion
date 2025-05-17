extends Control

func _ready():
	$VBoxContainer/SilabasButton.pressed.connect(_on_silabas_button_pressed)
	$VBoxContainer/ParejasButton.pressed.connect(_on_parejas_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_silabas_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/silabas/game.tscn")

func _on_parejas_button_pressed():
	get_tree().change_scene_to_file("res://scenes/minigames/parejas/parejas.tscn")

func _on_quit_button_pressed():
	get_tree().quit() 
