extends CanvasLayer

signal small_completion_finished
signal game_completion_finished

@onready var small_completion = $SmallCompletion
@onready var game_completion = $GameCompletion

# Preload star texture
var star_texture = preload("res://assets/images/es-tre-lla.jpg")

func _ready():
	# Hide both animations initially
	small_completion.visible = false
	game_completion.visible = false
	
	# Connect button signal
	game_completion.get_node("Content/ContinueButton").pressed.connect(_on_continue_pressed)

func show_small_completion(message: String = "¡Bien hecho!", icon_texture: Texture2D = null):
	"""
	Shows a small completion animation for minor achievements
	"""
	var content = small_completion.get_node("Content")
	var label = content.get_node("Label")
	var icon = content.get_node("Icon")
	
	# Set message and icon
	label.text = message
	if icon_texture:
		icon.texture = icon_texture
		icon.visible = true
	else:
		icon.visible = false
	
	# Reset and show
	small_completion.modulate.a = 0
	small_completion.scale = Vector2(0.5, 0.5)
	small_completion.visible = true
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(small_completion, "modulate:a", 1.0, 0.3)
	tween.tween_property(small_completion, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Animate out after delay
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(small_completion, "modulate:a", 0.0, 0.3)
	tween.tween_property(small_completion, "scale", Vector2(0.5, 0.5), 0.3).set_ease(Tween.EASE_IN)
	
	await tween.finished
	small_completion.visible = false
	emit_signal("small_completion_finished")

func show_game_completion(score_percentage: int = 100, stars_earned: int = 3, total_attempts: int = 0, correct_attempts: int = 0):
	"""
	Shows the full game completion animation with performance details
	"""
	var content = game_completion.get_node("Content")
	var title = content.get_node("Title")
	var score_label = content.get_node("Score")
	var stars_container = content.get_node("Stars")
	
	# Calculate performance metrics
	var accuracy = 0
	if total_attempts > 0:
		accuracy = (correct_attempts * 100) / total_attempts
	
	# Set title and score
	title.text = "¡Juego Completado!"
	score_label.text = "Precisión: %d%%" % accuracy
	
	# Set stars based on performance
	var star_nodes = [stars_container.get_node("Star1"), 
					  stars_container.get_node("Star2"), 
					  stars_container.get_node("Star3")]
	
	for i in range(star_nodes.size()):
		var star = star_nodes[i]
		if i < stars_earned:
			star.texture = star_texture
			star.modulate = Color(1, 1, 1, 1)
		else:
			star.modulate = Color(0.3, 0.3, 0.3, 0.5)
	
	# Reset and show
	game_completion.modulate.a = 0
	game_completion.scale = Vector2(0.8, 0.8)
	game_completion.visible = true
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(game_completion, "modulate:a", 1.0, 0.5)
	tween.tween_property(game_completion, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Animate stars appearing
	await tween.finished
	for i in range(stars_earned):
		var star = star_nodes[i]
		var star_tween = create_tween()
		star_tween.tween_property(star, "scale", Vector2(1.2, 1.2), 0.2)
		star_tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.2)
		await star_tween.finished
		await get_tree().create_timer(0.1).timeout

func _on_continue_pressed():
	"""
	Called when the continue button is pressed in the game completion screen
	"""
	# Animate out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(game_completion, "modulate:a", 0.0, 0.3)
	tween.tween_property(game_completion, "scale", Vector2(0.8, 0.8), 0.3)
	
	await tween.finished
	game_completion.visible = false
	emit_signal("game_completion_finished")

# Convenience functions for specific game types
func show_pair_matched():
	show_small_completion("¡Par encontrado! 🎉")

func show_syllable_correct():
	show_small_completion("¡Sílabas correctas! ✨")

func show_level_completed():
	show_small_completion("¡Nivel completado! 🌟")

func show_word_completed():
	show_small_completion("¡Palabra completada! 🎯")

func show_correct_answer():
	show_small_completion("¡Correcto! ✅")

func show_perfect_score():
	show_small_completion("¡Puntuación perfecta! 🌟")

func show_animal_found():
	show_small_completion("¡Animal encontrado! 🐾")

func show_letter_correct():
	show_small_completion("¡Letra correcta! 🔤")

func show_number_correct():
	show_small_completion("¡Número correcto! 🔢")

func show_color_matched():
	show_small_completion("¡Color encontrado! 🎨")

func show_shape_completed():
	show_small_completion("¡Forma completada! ⭐") 