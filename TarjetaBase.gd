extends Node2D

@export var silaba_id: int = 0  # Identificador único de la sílaba (por ejemplo, 0, 1, 2...)
@export var silaba_texto: String = ""  # Texto de la sílaba (opcional, para mostrar)

var dragging = false
var offset = Vector2.ZERO
var start_position = Vector2.ZERO

func _ready():
	start_position = position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				dragging = true
				offset = get_global_mouse_position() - global_position
			elif dragging:
				dragging = false
				# Al soltar, avisamos al gestor para comprobar si está sobre un hueco
				get_parent().comprobar_encaje(self)
				# Si no encajó, vuelve a su posición inicial
				if not is_in_slot():
					position = start_position
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - offset

func is_in_slot() -> bool:
	# Puedes implementar aquí la lógica para saber si la tarjeta está en un hueco
	# O dejarlo vacío y que el gestor lo controle
	return false

func get_rect() -> Rect2:
	var color_rect = $ColorRect
	if color_rect:
		return Rect2(Vector2.ZERO, color_rect.size)
	return Rect2(Vector2.ZERO, Vector2(120, 80))  # Tamaño por defecto
