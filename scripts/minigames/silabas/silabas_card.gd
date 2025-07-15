extends "res://scripts/cards/draggable_card.gd"
class_name SilabasCard

# Silabas-specific properties
# Note: card_text is inherited from StaticCard, so we don't need to declare it again

func _ready():
	super._ready()
	# Silabas cards use green border by default
	border_color = Color(0.2, 0.8, 0.2, 1.0)  # Green
	
	# Calculate responsive card size based on screen size
	var ventana = get_viewport_rect().size
	var card_width = max(80, ventana.x * 0.06)  # 6% of screen width, minimum 80px
	var card_height = max(40, ventana.y * 0.06)  # 6% of screen height, minimum 40px
	card_size = Vector2(card_width, card_height)
	
	setup_card_style()
	
	# Ensure drag functionality is enabled
	can_drag = true

func setup(silaba_text: String, silaba_id: int):
	"""Setup the card for silabas game"""
	card_text = silaba_text  # This uses the inherited property from StaticCard
	self.silaba_id = silaba_id
	is_image = false
	
	set_text(silaba_text)
	actualizar_label()
	
	# Ensure the card is draggable
	can_drag = true

func actualizar_label():
	"""Update the label text (legacy method for compatibility)"""
	if has_node("Label"):
		$Label.text = card_text.to_upper()
		$Label.add_theme_color_override("font_color", Color(0,0,0))

func volver_a_posicion_inicial():
	"""Return to initial position (legacy method for compatibility)"""
	return_to_start_position()

func _on_area_entered(area):
	"""Override area entered for silabas-specific behavior"""
	super._on_area_entered(area)

func _on_area_exited(area):
	"""Override area exited for silabas-specific behavior"""
	super._on_area_exited(area) 
