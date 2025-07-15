extends "res://scripts/cards/clickable_card.gd"
class_name ParejasCard

# Parejas-specific properties
@export var is_image_card: bool = false

func _ready():
	super._ready()
	# Parejas cards use purple border by default
	border_color = Color(0.7, 0.35, 0.9, 1)  # Purple
	setup_card_style()

func setup(texture: Texture2D = null, text: String = "", is_img: bool = false, id: int = -1, modulate_color: Color = Color(1,1,1,1)):
	"""Setup the card for parejas game"""
	is_image = is_img
	is_image_card = is_img
	pair_id = id
	
	if is_image:
		set_texture(texture)
		set_modulate_color(modulate_color)
	else:
		set_text(text)

func flip(show: bool):
	"""Override flip for parejas-specific behavior"""
	super.flip(show)
	# Add any parejas-specific flip animations here if needed

func mark_as_matched():
	"""Override mark_as_matched for parejas-specific behavior"""
	super.mark_as_matched()
	# Add any parejas-specific matching animations here if needed 