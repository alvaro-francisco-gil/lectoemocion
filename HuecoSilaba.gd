extends Node2D

@export var hueco_id: int = 0  # El identificador que debe coincidir con la tarjeta
var tarjeta_actual = null  # Referencia a la tarjeta que está en este hueco

func aceptar_tarjeta(tarjeta):
	tarjeta_actual = tarjeta
	tarjeta.position = position  # Centra la tarjeta en el hueco
	# Puedes añadir animación o sonido aquí
