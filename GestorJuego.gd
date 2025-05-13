extends Node2D

signal vidas_actualizadas(vidas_restantes)
signal juego_terminado

@export var escena_tarjeta : PackedScene
@export var escena_hueco : PackedScene

@onready var nodo_huecos = $Huecos
@onready var nodo_tarjetas = $Tarjetas
@onready var nodo_vidas = $Vidas

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
var tarjetas_colocadas = 0
var total_tarjetas = 0
var vidas = 3

func _ready():
	print("GestorJuego iniciado")
	
	# Asegurarse de que el nodo de vidas existe
	if not nodo_vidas:
		print("ERROR: Nodo de vidas no encontrado!")
		return
		
	# Conectar señales
	connect("vidas_actualizadas", Callable(nodo_vidas, "actualizar_vidas"))
	connect("juego_terminado", Callable(self, "_on_juego_terminado"))
	
	# Inicializar el juego
	seleccionar_palabra_aleatoria()
	total_tarjetas = nodo_tarjetas.get_child_count()
	emit_signal("vidas_actualizadas", vidas)

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

func intentar_colocar_tarjeta(tarjeta, hueco):
	if hueco.tarjeta_actual == null:
		if tarjeta.silaba_id == hueco.hueco_id:
			# Colocación correcta
			hueco.aceptar_tarjeta(tarjeta)
			tarjetas_colocadas += 1
			
			# Verificar si se completó el nivel
			if tarjetas_colocadas == total_tarjetas:
				print("¡Nivel completado!")
				await get_tree().create_timer(1.0).timeout
				siguiente_palabra()
		else:
			# Colocación incorrecta
			hueco.mostrar_error()
			vidas -= 1
			print("Vidas restantes: ", vidas)
			emit_signal("vidas_actualizadas", vidas)
			
			if vidas <= 0:
				print("¡Juego terminado! Sin vidas restantes")
				emit_signal("juego_terminado")
			else:
				# Devolver la tarjeta a su posición original
				tarjeta.position = tarjeta.start_position
				tarjeta.can_drag = true
				hueco.liberar_tarjeta()

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

func _on_juego_terminado():
	print("¡Juego terminado! Reiniciando...")
	# Esperar un momento antes de reiniciar
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
