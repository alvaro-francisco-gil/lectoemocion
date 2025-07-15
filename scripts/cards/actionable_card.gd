extends "res://scripts/cards/static_card.gd"
class_name ActionableCard

# Hover effect properties
@export var hover_scale: float = 1.1
@export var hover_duration: float = 0.2
@export var hover_color: Color = Color(1.1, 1.1, 1.1, 1.0)

var original_scale: Vector2
var is_hovered: bool = false

func _ready():
	super._ready()
	setup_hover_effects()

func setup_hover_effects():
	"""Setup hover effects for the card"""
	# Store original scale
	original_scale = scale
	
	# Set pivot to center for proper scaling
	pivot_offset = size / 2
	
	# Connect hover signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	"""Handle mouse enter event"""
	if not is_hovered:
		is_hovered = true
		_apply_hover_effect()

func _on_mouse_exited():
	"""Handle mouse exit event"""
	if is_hovered:
		is_hovered = false
		_remove_hover_effect()

func _apply_hover_effect():
	"""Apply hover effect with animation"""
	var target_scale = original_scale * hover_scale
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", target_scale, hover_duration)
	tween.tween_property(self, "modulate", hover_color, hover_duration)

func _remove_hover_effect():
	"""Remove hover effect with animation"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale, hover_duration)
	tween.tween_property(self, "modulate", Color.WHITE, hover_duration)

func set_hover_scale(scale_factor: float):
	"""Set the hover scale factor"""
	hover_scale = scale_factor

func set_hover_duration(duration: float):
	"""Set the hover animation duration"""
	hover_duration = duration

func set_hover_color(color: Color):
	"""Set the hover color"""
	hover_color = color 