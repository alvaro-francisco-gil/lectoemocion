extends Button

signal card_clicked(card)

var is_image: bool = false
var pair_id: int = -1
var is_flipped: bool = false
var is_matched: bool = false

func _ready():
	pressed.connect(_on_pressed)
	flip(false)
	# Borde morado
	var style = StyleBoxFlat.new()
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	style.border_color = Color(0.7, 0.35, 0.9, 1) # Morado un poco más oscuro
	style.bg_color = Color(1, 1, 1, 1)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_right = 20
	style.corner_radius_bottom_left = 20
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)
	add_theme_stylebox_override("focus", style)
	
	# Add cross-minigame hover and click effects
	if GameManager:
		GameManager.add_hover_effect(self)
		GameManager.add_click_feedback(self)

func setup(texture: Texture2D = null, text: String = "", is_img: bool = false, id: int = -1, modulate_color: Color = Color(1,1,1,1)):
	is_image = is_img
	pair_id = id
	
	if is_image:
		$TextureRect.texture = texture
		$TextureRect.visible = true
		$Label.visible = false
		$TextureRect.modulate = modulate_color
		
		# Asegurar que la imagen se ajuste correctamente al tamaño de la tarjeta
		$TextureRect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		$TextureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Forzar el tamaño de la tarjeta para consistencia
		custom_minimum_size = Vector2(200, 200)
		size = Vector2(200, 200)
		
		# Asegurar que el TextureRect no se salga de los límites
		$TextureRect.custom_minimum_size = Vector2(180, 180)  # Dejar espacio para el borde
		$TextureRect.size = Vector2(180, 180)
		
		# Centrar el TextureRect dentro de la tarjeta
		$TextureRect.position = Vector2(10, 10)  # 10px de margen para el borde
	else:
		$Label.text = text.replace("-", "").to_upper()
		$Label.modulate = Color(0,0,0,1)
		$TextureRect.visible = false
		$Label.visible = true
		
		# Forzar el tamaño de la tarjeta para consistencia
		custom_minimum_size = Vector2(200, 200)
		size = Vector2(200, 200)

func flip(show: bool):
	is_flipped = show

func mark_as_matched():
	is_matched = true
	modulate = Color(0.5, 1.0, 0.5, 1.0)  # Green tint
	disabled = true

func _on_pressed():
	if not is_matched:
		emit_signal("card_clicked", self) 
