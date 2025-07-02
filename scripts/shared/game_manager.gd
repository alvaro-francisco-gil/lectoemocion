extends Node

# Cross-minigame mechanics manager
# This singleton handles UI/UX features that should be consistent across all games

var custom_cursor_texture: Texture2D
var hover_scale: float = 1.1
var hover_duration: float = 0.2
var click_feedback_enabled: bool = true

func _ready():
	# Use built-in pointing hand cursor for friendly UX
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

# Add hover effect to any card or clickable element
func add_hover_effect(node: Control):
	if not node:
		return
	
	# Store original scale
	if not node.has_meta("original_scale"):
		node.set_meta("original_scale", node.scale)
	
	# Set pivot to center for proper scaling
	node.pivot_offset = node.size / 2
	
	# Connect hover signals
	node.mouse_entered.connect(_on_card_hover_start.bind(node))
	node.mouse_exited.connect(_on_card_hover_end.bind(node))

# Add click feedback to any clickable element
func add_click_feedback(node: Control):
	if not node or not click_feedback_enabled:
		return
	
	# Connect click signals
	if node.has_signal("pressed"):
		node.pressed.connect(_on_card_clicked.bind(node))
	elif node.has_signal("gui_input"):
		node.gui_input.connect(_on_card_input.bind(node))

# Hover start effect
func _on_card_hover_start(card: Control):
	var original_scale = card.get_meta("original_scale", Vector2.ONE)
	var target_scale = original_scale * hover_scale
	
	# Create smooth scale animation
	var tween = create_tween()
	tween.tween_property(card, "scale", target_scale, hover_duration)
	tween.tween_property(card, "modulate", Color(1.1, 1.1, 1.1, 1.0), hover_duration)

# Hover end effect
func _on_card_hover_end(card: Control):
	var original_scale = card.get_meta("original_scale", Vector2.ONE)
	
	# Create smooth scale animation back to normal
	var tween = create_tween()
	tween.tween_property(card, "scale", original_scale, hover_duration)
	tween.tween_property(card, "modulate", Color.WHITE, hover_duration)

# Click feedback effect
func _on_card_clicked(card: Control):
	var original_scale = card.get_meta("original_scale", Vector2.ONE)
	var click_scale = original_scale * 0.95
	
	# Quick shrink and expand effect
	var tween = create_tween()
	tween.tween_property(card, "scale", click_scale, 0.1)
	tween.tween_property(card, "scale", original_scale * hover_scale, 0.1)

# Handle input events for click feedback
func _on_card_input(event: InputEvent, card: Control):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_card_clicked(card)

# Enable/disable friendly cursor
func set_friendly_cursor(enabled: bool):
	if enabled:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# Configure hover effects
func configure_hover(scale: float = 1.1, duration: float = 0.2):
	hover_scale = scale
	hover_duration = duration

# Enable/disable click feedback
func set_click_feedback(enabled: bool):
	click_feedback_enabled = enabled

# Add sound effect support (for future expansion)
func play_hover_sound():
	# TODO: Add audio when sound assets are available
	pass

func play_click_sound():
	# TODO: Add audio when sound assets are available
	pass 