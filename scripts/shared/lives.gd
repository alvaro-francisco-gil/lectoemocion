extends Node2D

@onready var hearts = [
	$HBoxContainer/Heart1,
	$HBoxContainer/Heart2,
	$HBoxContainer/Heart3
]

var heart_texture = preload("res://assets/corazon.png")

func _ready():
	for heart in hearts:
		heart.texture = heart_texture

func actualizar_vidas(vidas_restantes: int):
	for i in range(hearts.size()):
		hearts[i].visible = i < vidas_restantes 