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
	# Forzar color de fondo verde turquesa
	if has_node("Background"):
		$Background.color = Color(0.2, 0.95, 0.85, 1.0)
	
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
	
	# Ajustar el fondo de nubes para que cubra toda la pantalla
	if has_node("FondoNubes") and $FondoNubes.texture:
		var ventana = get_viewport_rect().size
		var tex = $FondoNubes.texture
		var escala_x = ventana.x / tex.get_width()
		var escala_y = ventana.y / tex.get_height()
		var escala = max(escala_x, escala_y)
		$FondoNubes.scale = Vector2(escala, escala)
		$FondoNubes.position = ventana / 2
	
	# Inicializar el juego
	seleccionar_palabra_aleatoria()
	emit_signal("vidas_actualizadas", vidas)
	
	# Ajustar el fondo turquesa para que cubra toda la pantalla
	if has_node("Background"):
		$Background.position = Vector2.ZERO
		$Background.size = get_viewport_rect().size
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	centrar_vidas()

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
	
	# Colocar la imagen en y=215
	imagen_actual.position = Vector2(ventana.x / 2, 215)
	imagen_actual.centered = true
	
	add_child(imagen_actual)
	# Asegurar que el nodo Tarjetas esté al frente
	if has_node("Tarjetas"):
		move_child($Tarjetas, get_child_count() - 1)

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
	# Calcular posición inicial para centrar los huecos y tarjetas
	var espacio = 120
	var ancho_total = silabas.size() * espacio
	var posicion_inicial_x = (ventana.x - ancho_total) / 2 + espacio / 2
	# Crea los huecos en orden (arriba)
	for i in range(silabas.size()):
		var hueco = escena_hueco.instantiate()
		hueco.hueco_id = i
		hueco.position = Vector2(posicion_inicial_x + i * espacio, 400)  # Más abajo
		hueco.connect("tarjeta_colocada", Callable(self, "_on_tarjeta_colocada"))
		nodo_huecos.add_child(hueco)
		print("Hueco creado en posición: ", hueco.position)
	# Crea las tarjetas y las desordena (abajo)
	var silabas_desordenadas = silabas.duplicate()
	silabas_desordenadas.shuffle()
	for i in range(silabas.size()):
		var idx = silabas.find(silabas_desordenadas[i])
		var tarjeta = escena_tarjeta.instantiate()
		tarjeta.silaba_id = idx
		tarjeta.card_text = silabas_desordenadas[i]
		tarjeta.actualizar_label()
		tarjeta.position = Vector2(posicion_inicial_x + i * espacio, 500)  # Abajo
		nodo_tarjetas.add_child(tarjeta)
		print("Tarjeta creada: ", silabas_desordenadas[i], " con ID: ", idx)
	
	# Ajustar el ancho de la tira según el número de huecos
	ajustar_tira_silabas(silabas.size())

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
			# Devolver la tarjeta a su posición original inmediatamente
			tarjeta.position = tarjeta.start_position
			tarjeta.can_drag = true
			hueco.liberar_tarjeta()
			# Colocación incorrecta: poner todos los huecos en rojo
			for h in nodo_huecos.get_children():
				if h.has_method("mostrar_error_rojo"):
					h.mostrar_error_rojo()
			vidas -= 1
			print("Vidas restantes: ", vidas)
			emit_signal("vidas_actualizadas", vidas)
			# Restaurar todos los huecos tras 0.5 segundos
			await get_tree().create_timer(0.5).timeout
			for h in nodo_huecos.get_children():
				if h.has_method("restaurar_estado"):
					h.restaurar_estado()
			if vidas <= 0:
				print("¡Juego terminado! Sin vidas restantes")
				emit_signal("juego_terminado")

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

func _on_viewport_size_changed():
	if has_node("Background"):
		$Background.size = get_viewport_rect().size
	# Ajustar el fondo de nubes al cambiar el tamaño de la ventana
	if has_node("FondoNubes") and $FondoNubes.texture:
		var ventana = get_viewport_rect().size
		var tex = $FondoNubes.texture
		var escala_x = ventana.x / tex.get_width()
		var escala_y = ventana.y / tex.get_height()
		var escala = max(escala_x, escala_y)
		$FondoNubes.scale = Vector2(escala, escala)
		$FondoNubes.position = ventana / 2
	centrar_vidas()

func centrar_vidas():
	if has_node("Vidas"):
		var ventana = get_viewport_rect().size
		var vidas = $Vidas
		if vidas.has_node("HBoxContainer"):
			var hbox = vidas.get_node("HBoxContainer")
			vidas.position = Vector2(ventana.x / 2 - hbox.size.x / 2, 30)
		else:
			vidas.position = Vector2(ventana.x / 2, 30)

func ajustar_tira_silabas(num_huecos: int):
	if has_node("TiraSilabas"):
		var tira = $TiraSilabas
		# Si 4 huecos = 17cm (14cm + 3cm), entonces cada hueco = 4.25cm
		# Convertir a escala: 17cm = 680px (aproximadamente)
		var ancho_base_4_huecos = 680  # píxeles para 4 huecos (560 + 120)
		var ancho_por_hueco = ancho_base_4_huecos / 4.0
		var ancho_deseado = ancho_por_hueco * num_huecos
		
		# Calcular la escala X basándose en el ancho original de la textura
		if tira.texture:
			var ancho_original = tira.texture.get_width()
			var escala_x = ancho_deseado / ancho_original
			tira.scale.x = escala_x
			print("Tira ajustada: ", num_huecos, " huecos, escala X: ", escala_x)
