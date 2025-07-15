extends Panel
class_name StaticCard

# Abstract properties that must be defined by subclasses
@export var is_image: bool = false
@export var card_size: Vector2 = Vector2(200, 200)
@export var border_width: int = 6
@export var border_color: Color = Color(0.7, 0.35, 0.9, 1)
@export var background_color: Color = Color(1, 1, 1, 1)
@export var corner_radius: int = 20

# Card content
@export var card_texture: Texture2D
@export var card_text: String = ""

func _ready():
	setup_card_style()
	setup_card_content()

func setup_card_style():
	"""Setup the visual style of the card"""
	var style = StyleBoxFlat.new()
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.bg_color = background_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	
	# Apply style to the panel
	add_theme_stylebox_override("panel", style)
	
	# Set size
	custom_minimum_size = card_size
	size = card_size

func setup_card_content():
	"""Setup the content of the card (texture or text)"""
	if is_image and card_texture:
		setup_image_content()
	else:
		setup_text_content()

func setup_image_content():
	"""Setup card with image content"""
	if has_node("TextureRect"):
		$TextureRect.texture = card_texture
		$TextureRect.visible = true
		if has_node("Label"):
			$Label.visible = false
		
		# Configure texture display
		$TextureRect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		$TextureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Set texture size with margins
		var margin = border_width + 4
		$TextureRect.custom_minimum_size = card_size - Vector2(margin * 2, margin * 2)
		$TextureRect.size = card_size - Vector2(margin * 2, margin * 2)
		$TextureRect.position = Vector2(margin, margin)

func setup_text_content():
	"""Setup card with text content"""
	if has_node("Label"):
		$Label.text = card_text.to_upper()
		$Label.visible = true
		if has_node("TextureRect"):
			$TextureRect.visible = false
		
		# Configure text display
		$Label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func set_texture(texture: Texture2D):
	"""Set the texture for image cards"""
	card_texture = texture
	if is_image:
		setup_image_content()

func set_text(text: String):
	"""Set the text for text cards"""
	card_text = text
	if not is_image:
		setup_text_content()

func set_modulate_color(color: Color):
	"""Set the modulate color of the card"""
	modulate = color 