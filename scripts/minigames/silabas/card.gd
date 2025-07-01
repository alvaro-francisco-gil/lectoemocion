extends "res://scripts/shared/base_card.gd"

func _ready():
	super._ready()
	print("Tarjeta creada con texto: ", card_text, " y ID: ", silaba_id)

func _input_event(_viewport, event, _shape_idx):
	print("Input event recibido: ", event)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and can_drag:
				print("Iniciando drag de tarjeta: ", card_text)
				is_dragging = true
				drag_offset = position - get_global_mouse_position()
			elif is_dragging:
				print("Terminando drag de tarjeta: ", card_text)
				is_dragging = false
				if current_slot != null:
					print("Tarjeta sobre hueco: ", current_slot.hueco_id)
					# Buscar el nodo del juego de manera más robusta
					var game = get_tree().get_current_scene()
					if game and game.has_method("intentar_colocar_tarjeta"):
						print("Llamando a intentar_colocar_tarjeta")
						game.intentar_colocar_tarjeta(self, current_slot)
					else:
						print("ERROR: No se encontró el juego o no tiene el método intentar_colocar_tarjeta")
				else:
					print("Tarjeta no sobre ningún hueco, volviendo a posición inicial")
					volver_a_posicion_inicial()

func volver_a_posicion_inicial():
	position = start_position
	current_slot = null
	can_drag = true
	print("Tarjeta ", card_text, " volvió a posición inicial")

func _on_area_entered(area):
	if area.get_parent() is Node2D and area.get_parent().has_method("aceptar_tarjeta"):
		current_slot = area.get_parent()
		print("Tarjeta ", card_text, " entró en área de hueco: ", current_slot.hueco_id)

func _on_area_exited(area):
	if area.get_parent() == current_slot:
		current_slot = null
		print("Tarjeta ", card_text, " salió del área de hueco")
