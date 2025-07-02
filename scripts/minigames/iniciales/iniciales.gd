extends Control

const CardScene = preload("res://scenes/minigames/parejas/card.tscn")

var lives: int = 3
var current_letter: String = ""
var images_pool = []
var selected_images = []
var total_images_per_game: int = 10  # Parameter to control how many images to show
var remaining_images = []
var correct_selections = 0
var total_correct_for_letter = 0
var card_references = []  # Store references to cards for easy access
var card_to_image_map = {}  # Map card references to their image data

func _ready():
	load_images_pool()
	create_new_game()
	update_lives_display()
	if has_node("BotonVolver"):
		$BotonVolver.pressed.connect(_on_boton_volver_pressed)

func load_images_pool():
	# Only get filenames first (more efficient)
	var dir = DirAccess.open("res://assets/images")
	var image_files = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				# Skip .import files
				if file_name.ends_with(".import"):
					continue
					
				var word = file_name.get_basename().replace("-", "").capitalize()
				
				# Only include words that start with a letter (not numbers or special chars)
				if word.length() > 0 and word[0] >= "A" and word[0] <= "Z":
					image_files.append({
						"filename": file_name,
						"word": word,
						"initial_letter": word[0].to_upper()
					})
			
			file_name = dir.get_next()
		
		print("Total de archivos válidos encontrados: ", image_files.size())
		
		# Shuffle and select only the needed images
		image_files.shuffle()
		var selected_files = image_files.slice(0, total_images_per_game)
		
		# Load only the selected images
		for file_data in selected_files:
			var image_path = "res://assets/images/" + file_data.filename
			var texture = load(image_path)
			
			if texture:
				images_pool.append({
					"texture": texture,
					"word": file_data.word,
					"filename": file_data.filename,
					"initial_letter": file_data.initial_letter
				})
				print("Loaded: ", file_data.word, " (", file_data.filename, ")")
			else:
				print("Warning: Failed to load texture: ", image_path)
		
		print("Total de imágenes cargadas: ", images_pool.size())

func create_new_game():
	# Clear previous game
	clear_game()
	
	# Select random images for this game
	var shuffled_pool = images_pool.duplicate()
	shuffled_pool.shuffle()
	remaining_images = shuffled_pool.slice(0, total_images_per_game)
	
	# Create the big card container
	create_big_card()
	
	# Start with first letter
	select_new_letter()

func clear_game():
	# Clear big card
	if has_node("BigCard"):
		$BigCard.queue_free()
	
	# Clear letter display
	if has_node("LetterDisplay"):
		$LetterDisplay.queue_free()
	
	selected_images.clear()
	remaining_images.clear()
	card_references.clear()
	card_to_image_map.clear()
	correct_selections = 0
	total_correct_for_letter = 0

func create_big_card():
	# Create big card container
	var big_card = Panel.new()
	big_card.name = "BigCard"
	
	# Style the big card
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(1, 1, 1, 1)
	stylebox.border_width_left = 8
	stylebox.border_width_top = 8
	stylebox.border_width_right = 8
	stylebox.border_width_bottom = 8
	stylebox.border_color = Color(0.2, 0.8, 0.2, 1.0)  # Green border
	stylebox.corner_radius_top_left = 20
	stylebox.corner_radius_top_right = 20
	stylebox.corner_radius_bottom_right = 20
	stylebox.corner_radius_bottom_left = 20
	big_card.add_theme_stylebox_override("panel", stylebox)
	
	# Position and size the big card
	var ventana = get_viewport_rect().size
	big_card.size = Vector2(600, 400)
	big_card.position = Vector2(ventana.x / 2 - 300, 200)
	
	add_child(big_card)
	
	# Add images to the big card
	place_images_in_big_card(big_card)

func place_images_in_big_card(big_card: Panel):
	# Calculate grid layout
	var cols = 5  # 5 columns
	var rows = ceil(float(remaining_images.size()) / cols)
	var card_size = Vector2(80, 80)  # Smaller cards for the big card
	var spacing = 20
	
	# Calculate starting position to center the grid
	var total_width = cols * card_size.x + (cols - 1) * spacing
	var total_height = rows * card_size.y + (rows - 1) * spacing
	var start_x = (big_card.size.x - total_width) / 2
	var start_y = (big_card.size.y - total_height) / 2
	
	card_references.clear()  # Clear previous references
	
	for i in range(remaining_images.size()):
		var row = i / cols
		var col = i % cols
		
		var card = CardScene.instantiate()
		card.setup(remaining_images[i].texture, "", true, i, Color(1, 1, 1, 1))
		card.card_clicked.connect(_on_card_clicked.bind(i))
		
		# Position the card
		var pos_x = start_x + col * (card_size.x + spacing)
		var pos_y = start_y + row * (card_size.y + spacing)
		card.position = Vector2(pos_x, pos_y)
		
		# Random rotation
		card.rotation = randf_range(-0.3, 0.3)  # Random rotation between -17 and +17 degrees
		
		# Scale down the card
		card.scale = Vector2(0.4, 0.4)  # 40% of original size
		
		big_card.add_child(card)
		card_references.append(card)  # Store reference to the card
		card_to_image_map[card] = remaining_images[i]  # Map card to its image data

func select_new_letter():
	# Find all unique initial letters from remaining images
	var available_letters = []
	for image in remaining_images:
		if not available_letters.has(image.initial_letter):
			available_letters.append(image.initial_letter)
	
	if available_letters.size() == 0:
		# Game completed!
		show_game_completed()
		return
	
	# Select random letter
	current_letter = available_letters[randi() % available_letters.size()]
	
	# Count how many images start with this letter
	total_correct_for_letter = 0
	for image in remaining_images:
		if image.initial_letter == current_letter:
			total_correct_for_letter += 1
	
	# Create letter display
	create_letter_display()
	
	print("Nueva letra: ", current_letter, " - Imágenes correctas: ", total_correct_for_letter)

func create_letter_display():
	# Clear previous letter display
	if has_node("LetterDisplay"):
		print("Removing previous letter display")
		$LetterDisplay.free()  # Use free() instead of queue_free() for immediate removal
	
	# Create letter display
	var letter_display = Label.new()
	letter_display.name = "LetterDisplay"
	letter_display.text = current_letter
	letter_display.add_theme_font_size_override("font_size", 72)
	letter_display.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2, 1.0))  # Green color
	
	# Position at top center
	var ventana = get_viewport_rect().size
	letter_display.position = Vector2(ventana.x / 2 - 50, 100)
	
	add_child(letter_display)
	print("Created new letter display: ", current_letter)

func _on_card_clicked(clicked_card, image_index: int):
	print("Card clicked! Index: ", image_index)
	print("Current letter: ", current_letter)
	print("Remaining images size: ", remaining_images.size())
	print("Card references size: ", card_references.size())
	
	# Debug: Print all remaining images
	print("Remaining images:")
	for i in range(remaining_images.size()):
		print("  [", i, "] ", remaining_images[i].word, " (", remaining_images[i].initial_letter, ")")
	
	# Find the clicked image using the card-to-image mapping
	var clicked_image = card_to_image_map.get(clicked_card)
	
	if not clicked_image:
		print("ERROR: Could not find clicked image!")
		return
	
	print("Clicked image word: ", clicked_image.word, " - Initial letter: ", clicked_image.initial_letter)
	
	# Check if the image starts with the current letter
	if clicked_image.initial_letter == current_letter:
		# Correct selection!
		correct_selections += 1
		
		# Mark as selected
		selected_images.append(clicked_image)
		
		# Remove from remaining images
		remaining_images.erase(clicked_image)
		
		# Hide the card (make it invisible)
		print("Attempting to hide card: ", clicked_image.word)
		clicked_card.modulate = Color(1, 1, 1, 0)  # Make transparent
		clicked_card.disabled = true  # Disable interaction
		clicked_card.visible = false  # Also hide it completely
		
		print("¡Correcto! Imagen seleccionada: ", clicked_image.word)
		print("Correct selections: ", correct_selections, " / Total for letter: ", total_correct_for_letter)
		
		# Check if all images for this letter are found
		if correct_selections >= total_correct_for_letter:
			print("All images for letter '", current_letter, "' found! Moving to next letter...")
			correct_selections = 0
			total_correct_for_letter = 0
			selected_images.clear()
			
			# Check if game is completed
			if remaining_images.size() == 0:
				print("Game completed!")
				show_game_completed()
			else:
				print("Remaining images: ", remaining_images.size(), " - Selecting new letter...")
				# Select new letter
				await get_tree().create_timer(1.0).timeout
				select_new_letter()
		else:
			print("Still need ", total_correct_for_letter - correct_selections, " more images for letter '", current_letter, "'")
	else:
		# Wrong selection
		lives -= 1
		update_lives_display()
		
		if lives <= 0:
			show_game_over()
		else:
			# Show feedback for wrong selection
			# Flash red briefly
			clicked_card.modulate = Color(1, 0.3, 0.3, 1.0)
			await get_tree().create_timer(0.5).timeout
			clicked_card.modulate = Color(1, 1, 1, 1.0)

func update_lives_display():
	$Lives.actualizar_vidas(lives)

func show_game_completed():
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.title = "¡Juego Completado!"
	dialog.dialog_text = "¡Excelente! Has encontrado todas las imágenes."
	dialog.confirmed.connect(func(): get_tree().reload_current_scene())
	dialog.popup_centered()

func show_game_over():
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.title = "Fin del juego"
	dialog.dialog_text = "¡Se acabaron las vidas! Inténtalo de nuevo."
	dialog.confirmed.connect(func(): get_tree().reload_current_scene())
	dialog.popup_centered()

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 
