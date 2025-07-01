extends Node2D

signal vidas_actualizadas(vidas_restantes)
signal juego_terminado

@export var escena_tarjeta : PackedScene
@export var escena_hueco : PackedScene

@onready var nodo_huecos = $Huecos
@onready var nodo_tarjetas = $Tarjetas
@onready var nodo_vidas = $Vidas
@onready var nodo_fondo = $Fondo
@onready var boton_volver = $UI/BotonVolver

# Diccionario de palabras y sus sílabas
var palabras = {
	"elefante": {
		"silabas": ["e", "le", "fan", "te"],
		"imagen": "res://assets/animales/e-le-fan-te.png"
	},
	"mariposa": {
		"silabas": ["ma", "ri", "po", "sa"],
		"imagen": "res://assets/animales/ma-ri-po-sa.png"
	},
	"cerdo": {
		"silabas": ["cer", "do"],
		"imagen": "res://assets/animales/cer-do.png"
	}
}

var palabra_actual = ""
var tarjetas_colocadas = 0
var total_tarjetas = 0
var vidas = 3
var imagen_actual: Sprite2D

func _ready():
	print("GestorJuego iniciado")
	
	# Asegurarse de que el nodo de vidas existe
	if not nodo_vidas:
		print("ERROR: Nodo de vidas no encontrado!")
		return
		
	# Conectar señales
	connect("vidas_actualizadas", Callable(nodo_vidas, "actualizar_vidas"))
	connect("juego_terminado", Callable(self, "_on_juego_terminado"))
	boton_volver.pressed.connect(_on_boton_volver_pressed)
	
	# Ajustar el fondo a la pantalla
	ajustar_fondo()
	
	# Inicializar el juego
	seleccionar_palabra_aleatoria()
	emit_signal("vidas_actualizadas", vidas)

func ajustar_fondo():
	if nodo_fondo and nodo_fondo.texture:
		var ventana = get_viewport_rect().size
		var escala_x = ventana.x / nodo_fondo.texture.get_width()
		var escala_y = ventana.y / nodo_fondo.texture.get_height()
		var escala = max(escala_x, escala_y)  # Usamos max para cubrir toda la pantalla
		nodo_fondo.scale = Vector2(escala, escala)
		nodo_fondo.position = ventana / 2  # Centrar el fondo

func seleccionar_palabra_aleatoria():
	var palabras_disponibles = palabras.keys()
	palabra_actual = palabras_disponibles[randi() % palabras_disponibles.size()]
	print("Palabra seleccionada: ", palabra_actual)
	crear_partida(palabras[palabra_actual]["silabas"])
	actualizar_imagen(palabras[palabra_actual]["imagen"])

func actualizar_imagen(ruta_imagen: String):
	# Eliminar imagen anterior si existe
	if imagen_actual:
		imagen_actual.queue_free()
	
	# Crear nueva imagen
	imagen_actual = Sprite2D.new()
	var textura = load(ruta_imagen)
	imagen_actual.texture = textura
	
	# Obtener el tamaño de la ventana
	var ventana = get_viewport_rect().size
	
	# Calcular la escala para mantener las proporciones
	var tamaño_deseado = Vector2(300, 300)  # Tamaño máximo deseado (más grande)
	var escala_x = tamaño_deseado.x / textura.get_width()
	var escala_y = tamaño_deseado.y / textura.get_height()
	var escala_final = min(escala_x, escala_y)  # Usar la escala más pequeña para mantener proporciones
	
	imagen_actual.scale = Vector2(escala_final, escala_final)
	
	# Centrar la imagen en medio de la pantalla
	imagen_actual.position = Vector2(ventana.x / 2, ventana.y / 2)
	# Ajustar el origen de la imagen al centro
	imagen_actual.centered = true
	
	add_child(imagen_actual)

func crear_partida(silabas: Array):
	print("Creando partida con sílabas: ", silabas)
	# Limpia los huecos y tarjetas anteriores
	for c in nodo_huecos.get_children():
		c.queue_free()
	for c in nodo_tarjetas.get_children():
		c.queue_free()
	
	tarjetas_colocadas = 0  # Reiniciar contador
	total_tarjetas = silabas.size()  # Establecer el total de tarjetas basado en las sílabas
	
	# Obtener el tamaño de la ventana
	var ventana = get_viewport_rect().size
	
	# Calcular posición inicial para centrar los huecos
	var ancho_total_huecos = silabas.size() * 120  # 120 es el espacio entre huecos
	var posicion_inicial_x = (ventana.x - ancho_total_huecos) / 2
	
	# Crea los huecos en orden (abajo)
	for i in range(silabas.size()):
		var hueco = escena_hueco.instantiate()
		hueco.hueco_id = i
		hueco.position = Vector2(posicion_inicial_x + i * 120, ventana.y - 100)  # Posición abajo
		hueco.connect("tarjeta_colocada", Callable(self, "_on_tarjeta_colocada"))
		nodo_huecos.add_child(hueco)
		print("Hueco creado en posición: ", hueco.position)
	
	# Crea las tarjetas y las desordena (arriba)
	var silabas_desordenadas = silabas.duplicate()
	silabas_desordenadas.shuffle()
	
	for i in range(silabas.size()):
		var idx = silabas.find(silabas_desordenadas[i])
		var tarjeta = escena_tarjeta.instantiate()
		tarjeta.silaba_id = idx
		tarjeta.card_text = silabas_desordenadas[i]
		tarjeta.actualizar_label()
		tarjeta.position = Vector2(posicion_inicial_x + i * 120, 100)  # Posición arriba
		nodo_tarjetas.add_child(tarjeta)
		print("Tarjeta creada: ", silabas_desordenadas[i], " con ID: ", idx)

func intentar_colocar_tarjeta(tarjeta, hueco):
	if hueco.tarjeta_actual == null:
		if tarjeta.silaba_id == hueco.hueco_id:
			# Colocación correcta
			hueco.aceptar_tarjeta(tarjeta)
			tarjetas_colocadas += 1
			print("Tarjeta colocada correctamente. Total: ", tarjetas_colocadas, "/", total_tarjetas)
			
			# Verificar si se completó el nivel
			if tarjetas_colocadas == total_tarjetas:
				print("¡Nivel completado!")
				# Esperar un momento antes de cambiar de palabra
				get_tree().create_timer(1.0).timeout.connect(func():
					seleccionar_palabra_aleatoria()
				)
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

func _on_tarjeta_colocada(hueco_id: int, _tarjeta_id: int):
	# Ya no necesitamos esta función ya que la lógica está en intentar_colocar_tarjeta
	pass

# Función para añadir nuevas palabras al diccionario
func añadir_palabra(palabra: String, silabas: Array, imagen: String):
	palabras[palabra] = {
		"silabas": silabas,
		"imagen": imagen
	}

func _on_juego_terminado():
	print("¡Juego terminado! Reiniciando...")
	# Esperar un momento antes de reiniciar
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
