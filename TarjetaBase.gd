extends Node2D

@export var silaba_id: int = 0  # Identificador único de la sílaba (por ejemplo, 0, 1, 2...)
@export var silaba_texto: String = ""  # Texto de la sílaba (opcional, para mostrar)

var dragging = false
var offset = Vector2.ZERO
var start_position = Vector2.ZERO
var current_slot = null
var can_drag = true

func _ready():
	start_position = position
	# Actualizar el texto de la etiqueta
	if has_node("Label"):
		$Label.text = silaba_texto
	
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

func _process(_delta):
	# Buscar huecos cercanos
	if dragging:
		var gestor = get_node("/root/GestorJuego")
		if gestor and gestor.nodo_huecos:
			var hueco_mas_cercano = null
			var distancia_minima = 50.0  # Reducir la distancia de aceptación
			
			for hueco in gestor.nodo_huecos.get_children():
				var distancia = global_position.distance_to(hueco.global_position)
				if distancia < distancia_minima:
					distancia_minima = distancia
					hueco_mas_cercano = hueco
			
			if hueco_mas_cercano:
				current_slot = hueco_mas_cercano
			else:
				current_slot = null

func _input(event):
	if not can_drag:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				dragging = true
				offset = get_global_mouse_position() - global_position
			elif dragging:
				dragging = false
				if current_slot != null:
					var gestor = get_node("/root/GestorJuego")
					if gestor:
						gestor.intentar_colocar_tarjeta(self, current_slot)
				else:
					volver_a_posicion_inicial()
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - offset

func volver_a_posicion_inicial():
	position = start_position
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
