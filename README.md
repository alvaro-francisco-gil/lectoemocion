# LectoEmoción

A Godot-based educational game focused on literacy and emotional learning through interactive minigames.

## Project Structure

### Minigames
- **Silabas**: Syllable recognition and formation game
- **Parejas**: Matching pairs game
- **Cartapum**: Card-based memory game
- **Iniciales**: Initial letter recognition game

### Card System Architecture

The project uses a hierarchical card system for consistent UI components across minigames:

#### Base Classes
- **StaticCard** (`scripts/cards/static_card.gd`): Abstract base class for all cards
  - Handles basic card properties (text, image, background)
  - Provides common styling and layout functionality
  - Extends Panel for proper border support

#### Interactive Cards
- **ClickableCard** (`scripts/cards/clickable_card.gd`): Cards that respond to clicks
  - Adds hover effects and click animations
  - Used by parejas, cartapum, and iniciales games
  - Extends StaticCard with interactive behavior

- **DraggableCard** (`scripts/cards/draggable_card.gd`): Cards that can be dragged
  - Implements drag-and-drop functionality
  - Used by silabas game for syllable formation
  - Extends StaticCard with drag behavior

#### Minigame-Specific Cards
Each minigame has its own card scene that extends the appropriate base class:
- `scenes/minigames/silabas/silabas_card.tscn` - extends DraggableCard
- `scenes/minigames/parejas/parejas_card.tscn` - extends ClickableCard
- `scenes/minigames/cartapum/cartapum_card.tscn` - extends ClickableCard
- `scenes/minigames/iniciales/iniciales_card.tscn` - extends ClickableCard

### Shared Components
- **Game Manager**: Central game state management
- **Lives System**: Player lives tracking
- **Animation Manager**: Shared animation utilities
- **Firebase Integration**: Authentication and data persistence

## Development

This project is built with Godot 4 and uses GDScript for game logic. The card system provides a reusable foundation for creating consistent, interactive UI elements across all minigames. 