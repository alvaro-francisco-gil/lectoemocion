extends Control

const CardScene = preload("res://scenes/minigames/parejas/card.tscn")
const AnimationsScene = preload("res://scenes/shared/animations.tscn")

var animations: Node

var lives: int = 3
var current_word = ""
var current_word_data = {}
var image_cards = []
var word_data = {}  # Dictionary to store word data
var max_images_per_game: int = 3  # Parameter to control how many images to show

func _ready():
	# Add animations system
	animations = AnimationsScene.instantiate()
	add_child(animations)
	
	load_words_and_images()
	create_new_round()
	update_lives_display()
	if has_node("BotonVolver"):
		$BotonVolver.pressed.connect(_on_boton_volver_pressed)

func load_words_and_images():
	# Load images from the images folder
	var dir = DirAccess.open("res://assets/images")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				var image_path = "res://assets/images/" + file_name
				var texture = load(image_path)
				var word = file_name.get_basename().replace("-", "").capitalize()
				
				# Store word data
				if not word_data.has(word):
					word_data[word] = {
						"texture": texture,
						"word": word,
						"filename": file_name
					}
			
			file_name = dir.get_next()
		
		print("Total de palabras cargadas: ", word_data.size())

func create_new_round():
	# Clear previous cards
	clear_cards()
	
	# Select a random word
	var words = word_data.keys()
	if words.size() == 0:
		print("ERROR: No hay palabras disponibles!")
		return
	
	current_word = words[randi() % words.size()]
	current_word_data = word_data[current_word]
	
	# Create word card at the top
	var word_card = CardScene.instantiate()
	$VBoxContainer/WordCard.add_child(word_card)
	word_card.setup(null, current_word, false, -1)
	word_card.disabled = true  # Make it non-clickable
	
	# Force the word card to be much lower by changing its position
	$VBoxContainer/WordCard.position.y = 350
	$VBoxContainer/WordCard.position.x = 0
	print("DEBUG: Moving word card to position Y = 350")
	
	# Create image cards at the bottom
	var available_words = word_data.keys()
	available_words.erase(current_word)  # Remove the correct word
	
	# Keep the ImageCards in their current position
	$VBoxContainer/ImageCards.position.y = 400
	$VBoxContainer/ImageCards.position.x = 0
	print("DEBUG: Keeping images at position Y = 400")
	
	# Add the correct image
	var correct_card = CardScene.instantiate()
	$VBoxContainer/ImageCards.add_child(correct_card)
	correct_card.setup(current_word_data.texture, "", true, 0, Color(1, 1, 1, 1))
	correct_card.card_clicked.connect(_on_correct_card_clicked)
	image_cards.append(correct_card)
	
	# Add incorrect images
	for i in range(max_images_per_game - 1):
		if available_words.size() > 0:
			var random_word = available_words[randi() % available_words.size()]
			var wrong_card = CardScene.instantiate()
			$VBoxContainer/ImageCards.add_child(wrong_card)
			wrong_card.setup(word_data[random_word].texture, "", true, i + 1, Color(1, 1, 1, 1))
			wrong_card.card_clicked.connect(_on_wrong_card_clicked)
			image_cards.append(wrong_card)
			available_words.erase(random_word)
	
	# Shuffle the image cards
	shuffle_image_cards()

func clear_cards():
	# Clear word card
	for child in $VBoxContainer/WordCard.get_children():
		child.queue_free()
	
	# Clear image cards
	for child in $VBoxContainer/ImageCards.get_children():
		child.queue_free()
	
	image_cards.clear()

func shuffle_image_cards():
	# Get all image cards and shuffle their positions
	var cards = $VBoxContainer/ImageCards.get_children()
	var positions = []
	for card in cards:
		positions.append(card.position)
	
	positions.shuffle()
	
	for i in range(cards.size()):
		cards[i].position = positions[i]

func _on_correct_card_clicked(card):
	# Correct answer!
	card.mark_as_matched()
	
	# Show full game completion animation with stars
	animations.show_game_completion(100, 3, 1, 1)
	# Wait for the animation to finish before continuing
	await animations.game_completion_finished
	
	# Then create new round
	create_new_round()

func _on_wrong_card_clicked(card):
	# Wrong answer!
	lives -= 1
	update_lives_display()
	
	if lives <= 0:
		show_game_over(false)
	else:
		# Show the wrong choice briefly
		card.modulate = Color(1, 0.3, 0.3, 1.0)  # Red tint
		await get_tree().create_timer(1.0).timeout
		card.modulate = Color(1, 1, 1, 1.0)  # Reset color

func update_lives_display():
	$Lives.actualizar_vidas(lives)



func show_game_over(won: bool):
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.title = "Fin del juego"
	dialog.dialog_text = "¡Has perdido! Se acabaron las vidas."
	dialog.confirmed.connect(func(): get_tree().reload_current_scene())
	dialog.popup_centered()

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 
