# DEPRECATED: This file is deprecated. Use the new card hierarchy instead:
# - StaticCard: Basic card with no interaction
# - ActionableCard: Card with hover effects
# - ClickableCard: Card that can be clicked (for parejas, cartapum, iniciales)
# - DraggableCard: Card that can be dragged and dropped (for silabas)
#
# Each minigame now has its own specific card class that inherits from the appropriate base class.

extends Control

# This file is kept for backward compatibility but should not be used in new code.
# Please use the new card system instead.

@export var silaba_id: int = 0
@export var card_text: String = ""

var start_position = Vector2.ZERO
var current_slot = null
var can_drag = true
var is_dragging = false
var drag_offset: Vector2

func _ready():
	print("WARNING: Using deprecated base_card.gd. Please migrate to the new card system.")
	actualizar_label()
	start_position = position
	
	if has_node("Area2D"):
		$Area2D.monitoring = true
		$Area2D.monitorable = true
		$Area2D.connect("area_entered", Callable(self, "_on_area_entered"))
		$Area2D.connect("area_exited", Callable(self, "_on_area_exited"))
		$Area2D.connect("input_event", Callable(self, "_input_event"))
		
		if has_node("Area2D/CollisionShape2D"):
			var shape = $Area2D/CollisionShape2D.shape
			if shape is RectangleShape2D:
				shape.size = Vector2(100, 60)
	
	if GameManager:
		GameManager.add_hover_effect(self)
		GameManager.add_click_feedback(self)

func actualizar_label():
	if has_node("Label"):
		$Label.text = card_text.to_upper()
		$Label.add_theme_color_override("font_color", Color(0,0,0))

func _input(event):
	if is_dragging and event is InputEventMouseMotion:
		position = get_global_mouse_position() + drag_offset

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and can_drag:
				is_dragging = true
				drag_offset = position - get_global_mouse_position()
			else:
				is_dragging = false
				if current_slot != null:
					var game = get_tree().get_current_scene()
					if game and game.has_method("intentar_colocar_tarjeta"):
						game.intentar_colocar_tarjeta(self, current_slot)
				else:
					var game = get_tree().get_current_scene()
					if game and game.has_node("Huecos"):
						var min_dist = 99999
						var closest_slot = null
						for h in game.get_node("Huecos").get_children():
							var dist = position.distance_to(h.position)
							if dist < min_dist:
								min_dist = dist
								closest_slot = h
						if closest_slot != null and min_dist < 80:
							game.intentar_colocar_tarjeta(self, closest_slot)
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

func get_card_rect() -> Rect2:
	if has_node("Imagen"):
		return Rect2(Vector2.ZERO, $Imagen.size)
	return Rect2(Vector2.ZERO, Vector2(100, 60))
