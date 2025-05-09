extends Node2D

signal tarjeta_colocada(hueco_id, tarjeta_id)

@export var hueco_id: int = 0  # El identificador que debe coincidir con la tarjeta
var tarjeta_actual = null  # Referencia a la tarjeta que está en este hueco

func _ready():
	# Añadir un borde al hueco
	var border = ColorRect.new()
	border.size = Vector2(102, 62)  # Ligeramente más grande que el hueco
	border.position = Vector2(-1, -1)
	border.color = Color(0.5, 0.5, 0.5, 0.5)
	add_child(border)
	move_child(border, 0)  # Mover al fondo
	
	# Configurar el Area2D para detectar tarjetas
	$Area2D.monitoring = true
	$Area2D.monitorable = true
	
	# Ajustar el tamaño del CollisionShape2D para que coincida con el hueco
	var collision = $Area2D/CollisionShape2D
	if collision:
		collision.shape.size = Vector2(100, 60)  # Mismo tamaño que el ColorRect

func aceptar_tarjeta(tarjeta):
	if tarjeta_actual != null:
		tarjeta_actual.position = tarjeta_actual.start_position
	tarjeta_actual = tarjeta
	# Asegurarse de que la tarjeta se mueva al hueco
	tarjeta.global_position = global_position
	# Cambiar el color del borde para indicar que está ocupado
	$ColorRect.color = Color(0.7, 0.9, 0.7, 0.3)  # Verde claro
	# Emitir señal de tarjeta colocada
	emit_signal("tarjeta_colocada", hueco_id, tarjeta.silaba_id)

func liberar_tarjeta():
	if tarjeta_actual != null:
		tarjeta_actual.position = tarjeta_actual.start_position
	tarjeta_actual = null
	# Restaurar el color original
	$ColorRect.color = Color(0.8, 0.8, 0.8, 0.3)  # Gris original

func mostrar_error():
	# Parpadear en rojo para indicar error
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color(1, 0.3, 0.3, 0.3), 0.2)
	tween.tween_property($ColorRect, "color", Color(0.8, 0.8, 0.8, 0.3), 0.2)
