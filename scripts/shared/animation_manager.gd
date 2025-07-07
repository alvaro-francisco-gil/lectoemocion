extends Node
class_name AnimationManager

# Singleton-like pattern for easy access to animations
static var instance: AnimationManager

const AnimationsScene = preload("res://scenes/shared/animations.tscn")

var animations: Node

func _ready():
	instance = self
	animations = AnimationsScene.instantiate()
	add_child(animations)

# Static methods for easy access
static func show_small_completion(message: String = "¡Bien hecho!", icon_texture: Texture2D = null):
	if instance and instance.animations:
		instance.animations.show_small_completion(message, icon_texture)

static func show_game_completion(score_percentage: int = 100, stars_earned: int = 3, total_attempts: int = 0, correct_attempts: int = 0):
	if instance and instance.animations:
		instance.animations.show_game_completion(score_percentage, stars_earned, total_attempts, correct_attempts)

# Convenience methods for specific game types
static func show_pair_matched():
	show_small_completion("¡Par encontrado! 🎉")

static func show_syllable_correct():
	show_small_completion("¡Sílabas correctas! ✨")

static func show_level_completed():
	show_small_completion("¡Nivel completado! 🌟")

static func show_word_completed():
	show_small_completion("¡Palabra completada! 🎯")

static func show_correct_answer():
	show_small_completion("¡Correcto! ✅")

static func show_perfect_score():
	show_small_completion("¡Puntuación perfecta! 🌟")

# Connect to game completion signal
static func connect_game_completion(callback: Callable):
	if instance and instance.animations:
		instance.animations.game_completion_finished.connect(callback) 