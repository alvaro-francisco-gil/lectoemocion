extends "res://scripts/cards/actionable_card.gd"
class_name DraggableCard

# Drag properties
@export var can_drag: bool = true
@export var drag_offset: Vector2 = Vector2.ZERO

var is_dragging: bool = false
var start_position: Vector2
var current_slot = null
var silaba_id: int = 0

func _ready():
	super._ready()
	setup_drag_effects()

func setup_drag_effects():
	"""Setup drag and drop effects for the card"""
	# Store start position
	start_position = position
	
	# Set up Area2D for slot detection
	if has_node("Area2D"):
		$Area2D.monitoring = true
		$Area2D.monitorable = true
		$Area2D.connect("area_entered", Callable(self, "_on_area_entered"))
		$Area2D.connect("area_exited", Callable(self, "_on_area_exited"))
		$Area2D.connect("input_event", Callable(self, "_on_area_input_event"))
		
		# Configure collision shape
		if has_node("Area2D/CollisionShape2D"):
			var shape = $Area2D/CollisionShape2D.shape
			if shape is RectangleShape2D:
				shape.size = card_size

func _input(event: InputEvent):
	"""Handle input for dragging"""
	if is_dragging and event is InputEventMouseMotion:
		position = get_global_mouse_position() + drag_offset

func _on_area_input_event(_viewport, event, _shape_idx):
	"""Handle input events on the Area2D"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and can_drag:
				_start_drag()
			else:
				_end_drag()

func _start_drag():
	"""Start dragging the card"""
	is_dragging = true
	drag_offset = position - get_global_mouse_position()
	# Bring to front
	z_index = 10

func _end_drag():
	"""End dragging the card"""
	is_dragging = false
	z_index = 0
	
	if current_slot != null:
		# Try to place in current slot
		_attempt_place_in_slot(current_slot)
	else:
		# Auto-snap to nearest slot
		_auto_snap_to_nearest_slot()

func _on_area_entered(area):
	"""Handle entering a slot area"""
	if area.get_parent() is Node2D and area.get_parent().has_method("aceptar_tarjeta"):
		current_slot = area.get_parent()

func _on_area_exited(area):
	"""Handle exiting a slot area"""
	if area.get_parent() == current_slot:
		current_slot = null

func _attempt_place_in_slot(slot):
	"""Attempt to place the card in a slot"""
	if slot.has_method("aceptar_tarjeta"):
		# Get the game scene to handle the placement logic
		var game = get_tree().get_current_scene()
		if game and game.has_method("intentar_colocar_tarjeta"):
			game.intentar_colocar_tarjeta(self, slot)
		else:
			# Fallback to direct slot placement
			slot.aceptar_tarjeta(self)

func _auto_snap_to_nearest_slot():
	"""Auto-snap to the nearest slot if close enough"""
	var game = get_tree().get_current_scene()
	if game and game.has_node("Huecos"):
		var min_dist = 99999
		var closest_slot = null
		
		for slot in game.get_node("Huecos").get_children():
			var dist = position.distance_to(slot.position)
			if dist < min_dist:
				min_dist = dist
				closest_slot = slot
		
		if closest_slot != null and min_dist < 80:
			_attempt_place_in_slot(closest_slot)
		else:
			return_to_start_position()

func return_to_start_position():
	"""Return the card to its start position"""
	position = start_position
	current_slot = null
	can_drag = true

func set_silaba_id(id: int):
	"""Set the syllable ID for syllable games"""
	silaba_id = id

func get_silaba_id() -> int:
	"""Get the syllable ID"""
	return silaba_id

func set_can_drag(draggable: bool):
	"""Set whether the card can be dragged"""
	can_drag = draggable

func is_card_dragging() -> bool:
	"""Check if the card is currently being dragged"""
	return is_dragging

func get_current_slot():
	"""Get the current slot the card is in"""
	return current_slot

func get_card_rect() -> Rect2:
	"""Get the card's rectangle bounds"""
	return Rect2(Vector2.ZERO, card_size)

func set_start_position(new_position: Vector2):
	"""Set the start position for the card"""
	start_position = new_position 