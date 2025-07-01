extends Node2D

@export var silaba_id: int = 0  # Identificador único de la sílaba (por ejemplo, 0, 1, 2...)
@export var card_text: String = ""  # Texto genérico de la tarjeta (puede ser sílaba, letra, palabra, etc.)

var start_position = Vector2.ZERO
var current_slot = null
var can_drag = true
var is_dragging = false
var drag_offset: Vector2

func _ready():
	start_position = position
	actualizar_label()
	if get_parent():
		print("[DEBUG] Card parent type:", get_parent().get_class(), "name:", get_parent().name)
	if has_node("Area2D"):
		if has_node("Area2D/CollisionShape2D"):
			var shape = $Area2D/CollisionShape2D.shape
			if shape is RectangleShape2D:
				pass
		# Manual signal connection for debugging
		$Area2D.connect("input_event", Callable(self, "_input_event"))
	# Configurar el Area2D
	if has_node("Area2D"):
		$Area2D.monitoring = true
		$Area2D.monitorable = true
		$Area2D.connect("area_entered", Callable(self, "_on_area_entered"))
		$Area2D.connect("area_exited", Callable(self, "_on_area_exited"))
		# Asegurarse de que el CollisionShape2D tenga el tamaño correcto
		if has_node("Area2D/CollisionShape2D"):
			var shape = $Area2D/CollisionShape2D.shape
			if shape is RectangleShape2D:
				shape.size = Vector2(100, 60)  # Tamaño exacto de la tarjeta

func actualizar_label():
	if has_node("Label"):
		$Label.text = card_text

func _process(_delta):
	if is_dragging:
		position = get_global_mouse_position() + drag_offset

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and can_drag:
				is_dragging = true
				drag_offset = position - get_global_mouse_position()
			else:
				is_dragging = false

func volver_a_posicion_inicial():
	position = start_position
	current_slot = null
	can_drag = true

func _on_area_entered(area):
	if area.get_parent() is Node2D and area.get_parent().has_method("aceptar_tarjeta"):
		current_slot = area.get_parent()

func _on_area_exited(area):
	if area.get_parent() == current_slot:
		current_slot = null

func get_rect() -> Rect2:
	var color_rect = $ColorRect
	if color_rect:
		return Rect2(Vector2.ZERO, color_rect.size)
	return Rect2(Vector2.ZERO, Vector2(100, 60))  # Tamaño por defecto ajustado
