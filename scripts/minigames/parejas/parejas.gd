extends Control

const CardScene = preload("res://scenes/minigames/parejas/card.tscn")

var lives: int = 3
var selected_card = null
var pairs = []
var matched_pairs = 0
var max_pairs_per_game: int = 3  # Parameter to control how many pairs to show

func _ready():
	load_pairs()
	create_cards()
	update_lives_display()
	if has_node("BotonVolver"):
		$BotonVolver.pressed.connect(_on_boton_volver_pressed)

func load_pairs():
	# Load images from the images folder
	var dir = DirAccess.open("res://assets/images")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				var image_path = "res://assets/images/" + file_name
				var texture = load(image_path)
				var name = file_name.get_basename().capitalize()
				pairs.append({
					"texture": texture,
					"name": name
				})
			file_name = dir.get_next()
	
	# Shuffle the pairs
	pairs.shuffle()

func create_cards():
	# Limit to max_pairs_per_game pairs
	var pairs_to_use = pairs.slice(0, max_pairs_per_game)
	
	# Create image cards
	for i in range(pairs_to_use.size()):
		var card = CardScene.instantiate()
		$VBoxContainer/ImageCards.add_child(card)
		card.setup(pairs_to_use[i].texture, "", true, i, Color(1, 1, 1, 1))
		card.card_clicked.connect(_on_card_clicked)
	
	# Create text cards
	var text_cards = []
	for i in range(pairs_to_use.size()):
		var card = CardScene.instantiate()
		text_cards.append(card)
		card.setup(null, pairs_to_use[i].name, false, i)
		card.card_clicked.connect(_on_card_clicked)
	
	# Shuffle text cards
	text_cards.shuffle()
	for card in text_cards:
		$VBoxContainer/TextCards.add_child(card)

func _on_card_clicked(card):
	if selected_card == null:
		# First card selection
		selected_card = card
		card.flip(true)
	else:
		# Second card selection
		if selected_card.is_image == card.is_image:
			# Can't select two cards of the same type
			selected_card.flip(false)
			selected_card = null
			return
			
		if selected_card.pair_id == card.pair_id:
			# Match found
			selected_card.mark_as_matched()
			card.mark_as_matched()
			matched_pairs += 1
			
			if matched_pairs == max_pairs_per_game:
				# Game won
				show_game_over(true)
		else:
			# Wrong match
			lives -= 1
			update_lives_display()
			
			if lives <= 0:
				show_game_over(false)
			else:
				# Show the wrong match briefly
				card.flip(true)
				await get_tree().create_timer(1.0).timeout
				card.flip(false)
				selected_card.flip(false)
		
		selected_card = null

func update_lives_display():
	$Lives.actualizar_vidas(lives)

func show_game_over(won: bool):
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.title = "Fin del juego"
	dialog.dialog_text = "¡Has ganado!" if won else "¡Has perdido!"
	dialog.confirmed.connect(func(): get_tree().reload_current_scene())
	dialog.popup_centered()

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 
