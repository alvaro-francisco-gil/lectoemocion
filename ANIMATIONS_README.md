# Animation System for LectoEmoción

This document explains how to use the shared animation system in your minigames.

## Overview

The animation system provides two types of feedback animations:

1. **Small Completions** - For minor achievements (matching pairs, correct answers, etc.)
2. **Game Completions** - For when the entire minigame is finished

## How to Use

### 1. Add Animations to Your Minigame

In your minigame script, add this at the top:

```gdscript
const AnimationsScene = preload("res://scenes/shared/animations.tscn")
var animations: Node
```

### 2. Initialize in _ready()

```gdscript
func _ready():
	# Add animations system
	animations = AnimationsScene.instantiate()
	add_child(animations)
	
	# ... rest of your initialization code
```

### 3. Show Small Completions

For minor achievements, use these methods:

```gdscript
# Generic small completion
animations.show_small_completion("¡Bien hecho!")

# Predefined messages for common actions
animations.show_pair_matched()           # For matching pairs
animations.show_syllable_correct()       # For correct syllables
animations.show_level_completed()        # For completing a level
animations.show_word_completed()         # For completing a word
animations.show_correct_answer()         # For correct answers
animations.show_perfect_score()          # For perfect scores
animations.show_animal_found()           # For finding animals
animations.show_letter_correct()         # For correct letters
animations.show_number_correct()         # For correct numbers
animations.show_color_matched()          # For matching colors
animations.show_shape_completed()        # For completing shapes
```

### 4. Show Game Completion

For when the entire minigame is finished:

```gdscript
func show_game_completion():
	# Calculate performance metrics
	var stars_earned = 3  # Based on performance
	var total_attempts = 10  # Track total attempts
	var correct_attempts = 8  # Track correct attempts
	
	# Show game completion animation
	animations.show_game_completion(100, stars_earned, total_attempts, correct_attempts)
	animations.game_completion_finished.connect(func(): get_tree().reload_current_scene())
```

## Performance Tracking

To track performance for the game completion screen:

```gdscript
var total_attempts = 0
var correct_attempts = 0

# When player makes an attempt
func on_player_attempt(correct: bool):
	total_attempts += 1
	if correct:
		correct_attempts += 1
		animations.show_small_completion("¡Correcto!")
	else:
		# Handle incorrect attempt
		pass
```

## Custom Messages

You can create custom messages with icons:

```gdscript
# Custom message with icon
var custom_icon = preload("res://assets/IMÁGENES SUELTAS/corazon.png")
animations.show_small_completion("¡Amor encontrado!", custom_icon)

# Custom message without icon
animations.show_small_completion("¡Excelente trabajo!")
```

## Stars System

The game completion screen shows 1-3 stars based on performance:

- **3 Stars**: Perfect performance (all lives remaining)
- **2 Stars**: Good performance (1 life lost)
- **1 Star**: Basic completion (2+ lives lost)

## Integration Examples

### Parejas (Pairs) Minigame
- Shows `show_pair_matched()` when a pair is found
- Shows game completion with star rating based on remaining lives

### Silabas (Syllables) Minigame  
- Shows `show_syllable_correct()` when a syllable is placed correctly
- Shows `show_level_completed()` when a word is completed
- Tracks accuracy for game completion screen

## Adding New Animation Types

To add new animation types, edit `scripts/shared/animations.gd` and add new convenience functions:

```gdscript
func show_new_achievement():
	show_small_completion("¡Nuevo logro! 🏆")
```

## Tips

1. **Timing**: Small completions automatically disappear after 1 second
2. **Non-blocking**: Animations don't block game logic
3. **Reusable**: The same animation system works across all minigames
4. **Customizable**: You can pass custom messages and icons
5. **Performance**: Animations are lightweight and won't impact game performance

## Troubleshooting

- **Animation not showing**: Make sure you added the animations node to your scene
- **Scene not reloading**: Check that you connected the `game_completion_finished` signal
- **Performance issues**: Ensure you're not creating multiple animation instances 