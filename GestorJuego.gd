extends Node2D

@export var escena_tarjeta : PackedScene
@export var escena_hueco : PackedScene

@onready var nodo_huecos = $Huecos
@onready var nodo_tarjetas = $Tarjetas

# Diccionario de palabras y sus sílabas
var palabras = {
	"elefante": ["e", "le", "fan", "te"],
	"mariposa": ["ma", "ri", "po", "sa"],
	"sol": ["sol"],
	"luna": ["lu", "na"],
	"gato": ["ga", "to"],
	"perro": ["pe", "rro"],
	"casa": ["ca", "sa"],
	"árbol": ["ár", "bol"]
}

var palabra_actual = ""
var tarjeta_actual = null  # Para rastrear la tarjeta que se está arrastrando
var tarjetas_colocadas = 0  # Contador de tarjetas colocadas correctamente

func _ready():
	print("GestorJuego iniciado")
	# Selecciona una palabra aleatoria para empezar
	seleccionar_palabra_aleatoria()

func seleccionar_palabra_aleatoria():
	var palabras_disponibles = palabras.keys()
	palabra_actual = palabras_disponibles[randi() % palabras_disponibles.size()]
	print("Palabra seleccionada: ", palabra_actual)
	crear_partida(palabras[palabra_actual])

func siguiente_palabra():
	var palabras_disponibles = palabras.keys()
	var indice_actual = palabras_disponibles.find(palabra_actual)
	var siguiente_indice = (indice_actual + 1) % palabras_disponibles.size()
	palabra_actual = palabras_disponibles[siguiente_indice]
	print("Nueva palabra seleccionada: ", palabra_actual)
	crear_partida(palabras[palabra_actual])

func crear_partida(silabas: Array):
	print("Creando partida con sílabas: ", silabas)
	# Limpia los huecos y tarjetas anteriores
	for c in nodo_huecos.get_children():
		c.queue_free()
	for c in nodo_tarjetas.get_children():
		c.queue_free()
	
	tarjetas_colocadas = 0  # Reiniciar contador
	
	# Crea los huecos en orden
	for i in range(silabas.size()):
		var hueco = escena_hueco.instantiate()
		hueco.hueco_id = i
		hueco.position = Vector2(100 + i * 120, 200)  # Ajusta posición según tu diseño
		hueco.connect("tarjeta_colocada", Callable(self, "_on_tarjeta_colocada"))
		nodo_huecos.add_child(hueco)
		print("Hueco creado en posición: ", hueco.position)
	
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
		print("Tarjeta creada: ", silabas_desordenadas[i], " con ID: ", idx)

func _on_tarjeta_colocada(hueco_id: int, tarjeta_id: int):
	if hueco_id == tarjeta_id:
		tarjetas_colocadas += 1
		print("Tarjeta colocada correctamente. Total: ", tarjetas_colocadas)
		
		# Verificar si todas las tarjetas están colocadas
		if tarjetas_colocadas == palabras[palabra_actual].size():
			print("¡Palabra completada!")
			# Esperar un momento antes de pasar a la siguiente palabra
			await get_tree().create_timer(1.0).timeout
			siguiente_palabra()

# Función para añadir nuevas palabras al diccionario
func añadir_palabra(palabra: String, silabas: Array):
	palabras[palabra] = silabas

# Función para comprobar si una tarjeta está en el hueco correcto
func comprobar_encaje(tarjeta):
	print("Comprobando encaje de tarjeta: ", tarjeta.silaba_texto, " con ID: ", tarjeta.silaba_id)
	var tarjeta_pos = tarjeta.global_position
	var encajada = false
	var hueco_mas_cercano = null
	var distancia_minima = 50.0  # Reducimos la distancia para hacer más preciso el encaje
	
	# Comprueba cada hueco
	for hueco in nodo_huecos.get_children():
		var distancia = tarjeta_pos.distance_to(hueco.global_position)
		print("Distancia a hueco ", hueco.hueco_id, ": ", distancia)
		if distancia < distancia_minima:
			distancia_minima = distancia
			hueco_mas_cercano = hueco
	
	# Si encontramos un hueco cercano
	if hueco_mas_cercano:
		print("Hueco más cercano encontrado: ", hueco_mas_cercano.hueco_id)
		# Si el hueco está vacío o tiene la misma tarjeta
		if hueco_mas_cercano.tarjeta_actual == null or hueco_mas_cercano.tarjeta_actual == tarjeta:
			# Si el ID de la tarjeta coincide con el ID del hueco
			if tarjeta.silaba_id == hueco_mas_cercano.hueco_id:
				print("¡Encaje correcto!")
				hueco_mas_cercano.aceptar_tarjeta(tarjeta)
				encajada = true
			else:
				print("Encaje incorrecto - IDs no coinciden")
				# Mostrar error si la tarjeta no coincide
				hueco_mas_cercano.mostrar_error()
				tarjeta.position = tarjeta.start_position
	else:
		print("No se encontró hueco cercano")
	
	# Si la tarjeta no encajó en ningún hueco, vuelve a su posición inicial
	if not encajada:
		print("Tarjeta no encajada, volviendo a posición inicial")
		tarjeta.position = tarjeta.start_position
