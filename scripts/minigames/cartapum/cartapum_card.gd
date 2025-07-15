extends "res://scripts/cards/clickable_card.gd"
class_name CartapumCard

# Cartapum-specific properties
@export var is_image_card: bool = false

func _ready():
	super._ready()
	# Cartapum cards use blue border by default
	border_color = Color(0.2, 0.6, 0.9, 1.0)  # Blue
	setup_card_style()

func setup(texture: Texture2D = null, text: String = "", is_img: bool = false, id: int = -1, modulate_color: Color = Color(1,1,1,1)):
	"""Setup the card for cartapum game"""
	is_image = is_img
	is_image_card = is_img
	pair_id = id
	
	if is_image:
		set_texture(texture)
		set_modulate_color(modulate_color)
	else:
		set_text(text)

func mark_as_matched():
	"""Override mark_as_matched for cartapum-specific behavior"""
	super.mark_as_matched()
	# Add any cartapum-specific matching animations here if needed 