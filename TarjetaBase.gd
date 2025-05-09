extends Node2D

@export var silaba_id: int = 0  # Identificador único de la sílaba (por ejemplo, 0, 1, 2...)
@export var silaba_texto: String = ""  # Texto de la sílaba (opcional, para mostrar)

var dragging = false
var offset = Vector2.ZERO
var start_position = Vector2.ZERO

func _ready():
	start_position = position
	print("Tarjeta creada: ", silaba_texto, " en posición: ", position)
	# Actualizar el texto de la etiqueta
	if has_node("Label"):
		$Label.text = silaba_texto

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				print("Iniciando arrastre de tarjeta: ", silaba_texto)
				dragging = true
				offset = get_global_mouse_position() - global_position
			elif dragging:
				print("Soltando tarjeta: ", silaba_texto)
				dragging = false
				# Al soltar, avisamos al gestor para comprobar si está sobre un hueco
				var gestor = get_node("/root/GestorJuego")
				if gestor:
					print("Llamando a comprobar_encaje en GestorJuego")
					gestor.comprobar_encaje(self)
				else:
					print("ERROR: No se encontró el nodo GestorJuego")
				# Si no encajó, vuelve a su posición inicial
				if not is_in_slot():
					position = start_position
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - offset

func is_in_slot() -> bool:
	# Puedes implementar aquí la lógica para saber si la tarjeta está en un hueco
	# O dejarlo vacío y que el gestor lo controle
	return false

func get_rect() -> Rect2:
	var color_rect = $ColorRect
	if color_rect:
		return Rect2(Vector2.ZERO, color_rect.size)
	return Rect2(Vector2.ZERO, Vector2(120, 80))  # Tamaño por defecto
