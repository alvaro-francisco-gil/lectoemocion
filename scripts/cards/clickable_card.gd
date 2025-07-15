extends "res://scripts/cards/actionable_card.gd"
class_name ClickableCard

signal card_clicked(card)

# Click properties
@export var click_scale: float = 0.95
@export var click_duration: float = 0.1
@export var is_disabled: bool = false

var is_flipped: bool = false
var is_matched: bool = false
var pair_id: int = -1

func _ready():
	super._ready()
	setup_click_effects()

func setup_click_effects():
	"""Setup click effects for the card"""
	# Connect click signal
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	"""Handle input events for clicking"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_disabled and not is_matched:
			_apply_click_effect()
			emit_signal("card_clicked", self)

func _apply_click_effect():
	"""Apply click feedback effect"""
	var click_scale_target = original_scale * click_scale
	
	var tween = create_tween()
	tween.tween_property(self, "scale", click_scale_target, click_duration)
	tween.tween_property(self, "scale", original_scale * hover_scale, click_duration)

func flip(show: bool):
	"""Flip the card (for memory games)"""
	is_flipped = show
	# This can be overridden by subclasses for specific flip animations

func mark_as_matched():
	"""Mark the card as matched"""
	is_matched = true
	is_disabled = true
	modulate = Color(0.5, 1.0, 0.5, 1.0)  # Green tint

func set_pair_id(id: int):
	"""Set the pair ID for matching games"""
	pair_id = id

func get_pair_id() -> int:
	"""Get the pair ID"""
	return pair_id

func set_disabled(disabled: bool):
	"""Set the disabled state of the card"""
	is_disabled = disabled
	if disabled:
		modulate = Color(0.7, 0.7, 0.7, 1.0)  # Gray out
	else:
		modulate = Color.WHITE

func is_card_matched() -> bool:
	"""Check if the card is matched"""
	return is_matched

func is_card_flipped() -> bool:
	"""Check if the card is flipped"""
	return is_flipped 