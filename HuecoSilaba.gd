extends Node2D

const TarjetaBase = preload("res://TarjetaBase.gd")

signal tarjeta_colocada(hueco_id, tarjeta_id)

@onready var area = $Area2D
@onready var sprite = $Sprite2D
@onready var label = $Label

var hueco_id = -1
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
	var gestor = get_node("/root/GestorJuego")
	if gestor and gestor.nodo_tarjetas:
		for tarjeta in gestor.nodo_tarjetas.get_children():
			if tarjeta is TarjetaBase and tarjeta.dragging:
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

func aceptar_tarjeta(tarjeta):
	tarjeta_actual = tarjeta
	tarjeta.global_position = global_position  # Usar global_position en lugar de position
	tarjeta.can_drag = false
	emit_signal("tarjeta_colocada", hueco_id, tarjeta.silaba_id)

func mostrar_error():
	if sprite:
		var tween = create_tween()
		tween.parallel().tween_property(sprite, "modulate", Color(1, 0, 0, 1), 0.1)
		tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
		tween.set_loops(3)

func liberar_tarjeta():
	if tarjeta_actual != null:
		tarjeta_actual.position = tarjeta_actual.start_position
		tarjeta_actual.can_drag = true
	tarjeta_actual = null
