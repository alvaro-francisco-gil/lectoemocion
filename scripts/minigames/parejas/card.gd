extends Button

signal card_clicked(card)

var is_image: bool = false
var pair_id: int = -1
var is_flipped: bool = false
var is_matched: bool = false

func _ready():
	pressed.connect(_on_pressed)
	flip(false)

func setup(texture: Texture2D = null, text: String = "", is_img: bool = false, id: int = -1):
	is_image = is_img
	pair_id = id
	
	if is_image:
		$TextureRect.texture = texture
		$TextureRect.visible = true
		$Label.visible = false
	else:
		$Label.text = text
		$TextureRect.visible = false
		$Label.visible = true

func flip(show: bool):
	is_flipped = show
	modulate.a = 1.0 if show else 0.3

func mark_as_matched():
	is_matched = true
	modulate = Color(0.5, 1.0, 0.5, 1.0)  # Green tint
	disabled = true

func _on_pressed():
	if not is_matched:
		emit_signal("card_clicked", self) 