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

func _on_area_entered(area_other):
	if area_other.get_parent() is TarjetaBase:
		var tarjeta = area_other.get_parent()
		tarjeta.current_slot = self
		print("Tarjeta entró en hueco: ", hueco_id)

func _on_area_exited(area_other):
	if area_other.get_parent() is TarjetaBase:
		var tarjeta = area_other.get_parent()
		if tarjeta.current_slot == self:
			tarjeta.current_slot = null
			print("Tarjeta salió del hueco: ", hueco_id)



func aceptar_tarjeta(tarjeta):
	tarjeta_actual = tarjeta
	tarjeta.current_slot = self
	tarjeta.can_drag = false
	tarjeta.position = position
	print("Tarjeta aceptada en hueco: ", hueco_id)
	emit_signal("tarjeta_colocada", hueco_id, tarjeta.silaba_id)

func mostrar_error():
	var stylebox = $Panel.get("theme_override_styles/panel")
	var original_color = stylebox.bg_color
	# Ocultar la interrogación blanca
	if has_node("Label"):
		$Label.visible = false
	stylebox.bg_color = Color(1, 0.3, 0.3, 1)
	await get_tree().create_timer(0.5).timeout
	stylebox.bg_color = original_color
	# Volver a mostrar la interrogación
	if has_node("Label"):
		$Label.visible = true

func mostrar_error_rojo():
	var stylebox = $Panel.get("theme_override_styles/panel")
	stylebox.bg_color = Color(1, 0.3, 0.3, 1)
	if has_node("Label"):
		$Label.visible = false

func liberar_tarjeta():
	if tarjeta_actual:
		tarjeta_actual.current_slot = null
		tarjeta_actual = null

func restaurar_estado():
	var stylebox = $Panel.get("theme_override_styles/panel")
	stylebox.bg_color = Color(1, 1, 1, 1)
	if has_node("Label"):
		$Label.visible = true
