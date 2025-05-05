extends Node2D

@export var escena_tarjeta : PackedScene
@export var escena_hueco : PackedScene

@onready var nodo_huecos = $Huecos
@onready var nodo_tarjetas = $Tarjetas

func _ready():
	# Aquí defines la palabra en sílabas para la partida inicial
	crear_partida(['e', 'le', 'fan', 'te'])

func crear_partida(silabas: Array):
	# Limpia los huecos y tarjetas anteriores
	for c in nodo_huecos.get_children():
		c.queue_free()
	for c in nodo_tarjetas.get_children():
		c.queue_free()
	
	# Crea los huecos en orden
	for i in range(silabas.size()):
		var hueco = escena_hueco.instantiate()
		hueco.hueco_id = i
		hueco.position = Vector2(100 + i * 120, 200)  # Ajusta posición según tu diseño
		nodo_huecos.add_child(hueco)
	
	# Crea las tarjetas y las desordena
	var silabas_desordenadas = silabas.duplicate()
	silabas_desordenadas.shuffle()
	
	for i in range(silabas.size()):
		var idx = silabas.find(silabas_desordenadas[i])
		var tarjeta = escena_tarjeta.instantiate()
		tarjeta.silaba_id = idx
		tarjeta.silaba_texto = silabas_desordenadas[i]
		tarjeta.position = Vector2(100 + i * 120, 400)  # Ajusta posición según tu diseño
		nodo_tarjetas.add_child(tarjeta)
