extends "res://scripts/shared/base_card.gd"

func _ready():
	super._ready()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and can_drag:
				is_dragging = true
				drag_offset = position - get_global_mouse_position()
			elif is_dragging:
				is_dragging = false
				if current_slot != null:
					# Buscar el nodo del juego de manera más robusta
					var game = get_tree().get_current_scene()
					if game and game.has_method("intentar_colocar_tarjeta"):
						game.intentar_colocar_tarjeta(self, current_slot)
				else:
					volver_a_posicion_inicial()

func volver_a_posicion_inicial():
	position = start_position
	current_slot = null
	can_drag = true

func _on_area_entered(area):
	if area.get_parent() is Node2D and area.get_parent().has_method("aceptar_tarjeta"):
		current_slot = area.get_parent()

func _on_area_exited(area):
	if area.get_parent() == current_slot:
		current_slot = null
