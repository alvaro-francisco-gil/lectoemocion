extends Node2D

const TarjetaBase = preload("res://scripts/shared/base_card.gd")

signal tarjeta_colocada(hueco_id: int, tarjeta_id: int)

@onready var area = $Area2D
@onready var label = $Label

var hueco_id: int
var tarjeta_actual = null

func _ready():
	# Configurar el área de detección
	area.monitoring = true
	area.monitorable = true
	
	# Asegurarse de que el CollisionShape2D tenga el tamaño correcto
	var shape_size = Vector2(100, 60)  # Tamaño exacto del hueco
	if has_node("Area2D/CollisionShape2D"):
		var shape = $Area2D/CollisionShape2D.shape
		if shape is RectangleShape2D:
			shape.size = shape_size
	
	# Conectar señales
	area.connect("area_entered", Callable(self, "_on_area_entered"))
	area.connect("area_exited", Callable(self, "_on_area_exited"))

func _process(_delta):
	# Buscar tarjetas cercanas
	var gestor = get_tree().get_current_scene()
	if gestor and gestor.nodo_tarjetas:
		for tarjeta in gestor.nodo_tarjetas.get_children():
			if tarjeta is TarjetaBase and tarjeta.is_dragging:
				var distancia = global_position.distance_to(tarjeta.global_position)
				if distancia < 50.0:  # Reducir la distancia de aceptación
					tarjeta.current_slot = self

func _on_area_entered(area_other):
	if area_other.get_parent() is TarjetaBase:
		var tarjeta = area_other.get_parent()
		tarjeta.current_slot = self

func _on_area_exited(area_other):
	if area_other.get_parent() is TarjetaBase:
		var tarjeta = area_other.get_parent()
		if tarjeta.current_slot == self:
			tarjeta.current_slot = null

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if tarjeta_actual != null:
				liberar_tarjeta()

func aceptar_tarjeta(tarjeta):
	tarjeta_actual = tarjeta
	tarjeta.current_slot = self
	tarjeta.can_drag = false
	tarjeta.position = position
	emit_signal("tarjeta_colocada", hueco_id, tarjeta.silaba_id)

func mostrar_error():
	var stylebox = $Panel.get("theme_override_styles/panel")
	var original_color = stylebox.bg_color
	stylebox.bg_color = Color(1, 0.3, 0.3, 1)
	await get_tree().create_timer(0.5).timeout
	stylebox.bg_color = original_color

func liberar_tarjeta():
	if tarjeta_actual:
		tarjeta_actual.current_slot = null
		tarjeta_actual = null
