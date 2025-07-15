extends Node2D

signal vidas_actualizadas(vidas_restantes)
signal juego_terminado

@export var escena_tarjeta : PackedScene = preload("res://scenes/minigames/silabas/silabas_card.tscn")
@export var escena_hueco : PackedScene

const AnimationsScene = preload("res://scenes/shared/animations.tscn")

@onready var nodo_huecos = $Huecos
@onready var nodo_tarjetas = $Tarjetas
@onready var nodo_vidas = $Vidas
@onready var nodo_fondo = $Fondo
@onready var boton_volver = $UI/BotonVolver

# Dictionary to store words and their data (loaded dynamically)
var palabras = {}
var palabra_actual = ""
var tarjetas_colocadas = 0
var total_tarjetas = 0
var vidas = 3
var imagen_actual: Control
var animations: Node
var total_attempts = 0
var correct_attempts = 0
var acierto_sound: AudioStreamPlayer
var error_sound: AudioStreamPlayer

func _ready():
	print("GestorJuego iniciado")
	# Forzar color de fondo verde turquesa
	if has_node("Background"):
		$Background.color = Color(0.2, 0.95, 0.85, 1.0)
	
	# Add animations system
	animations = AnimationsScene.instantiate()
	add_child(animations)
	
	# Load success sound
	var sound_stream = load("res://assets/sounds/sonido acierto.mp3")
	if sound_stream:
		print("Sonido de acierto cargado correctamente")
		acierto_sound = AudioStreamPlayer.new()
		acierto_sound.stream = sound_stream
		add_child(acierto_sound)
	else:
		print("ERROR: No se pudo cargar el sonido de acierto")
	
	# Load error sound
	var error_stream = load("res://assets/sounds/sonido error.mp3")
	if error_stream:
		print("Sonido de error cargado correctamente")
		error_sound = AudioStreamPlayer.new()
		error_sound.stream = error_stream
		add_child(error_sound)
	else:
		print("ERROR: No se pudo cargar el sonido de error")
	
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
	
	# Cargar palabras dinámicamente desde assets/images
	cargar_palabras_desde_imagenes()
	
	# Inicializar el juego
	seleccionar_palabra_aleatoria()
	emit_signal("vidas_actualizadas", vidas)
	
	# Ajustar el fondo turquesa para que cubra toda la pantalla
	if has_node("Background"):
		$Background.position = Vector2.ZERO
		$Background.size = get_viewport_rect().size
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	centrar_vidas()

func cargar_palabras_desde_imagenes():
	var dir = DirAccess.open("res://assets/images")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				# Extraer la palabra y sílabas del nombre del archivo
				var nombre_base = file_name.get_basename()
				if nombre_base.contains("-"):
					var silabas = nombre_base.split("-")
					var palabra = nombre_base.replace("-", "")
					
					# Solo incluir palabras con al menos 2 sílabas
					if silabas.size() >= 2:
						palabras[palabra] = {
							"silabas": silabas,
							"imagen": "res://assets/images/" + file_name
						}
						print("Palabra cargada: ", palabra, " con sílabas: ", silabas)
			
			file_name = dir.get_next()
		
		print("Total de palabras cargadas: ", palabras.size())
	else:
		print("ERROR: No se pudo abrir el directorio assets/images")

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
	if palabras_disponibles.size() == 0:
		print("ERROR: No hay palabras disponibles!")
		return
		
	palabra_actual = palabras_disponibles[randi() % palabras_disponibles.size()]
	print("Palabra seleccionada: ", palabra_actual)
	crear_partida(palabras[palabra_actual]["silabas"])
	actualizar_imagen(palabras[palabra_actual]["imagen"])

func actualizar_imagen(ruta_imagen: String):
	# Eliminar imagen anterior si existe
	if imagen_actual:
		imagen_actual.queue_free()
	
	# Crear contenedor para la imagen con borde
	var contenedor = Control.new()
	contenedor.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Crear el panel con borde verde transparente
	var panel = Panel.new()
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0)  # Transparente
	stylebox.border_width_left = 8
	stylebox.border_width_top = 8
	stylebox.border_width_right = 8
	stylebox.border_width_bottom = 8
	stylebox.border_color = Color(0.2, 0.8, 0.2, 1.0)  # Verde para el borde
	stylebox.corner_radius_top_left = 15
	stylebox.corner_radius_top_right = 15
	stylebox.corner_radius_bottom_right = 15
	stylebox.corner_radius_bottom_left = 15
	panel.add_theme_stylebox_override("panel", stylebox)
	
	# Crear nueva imagen
	var sprite_imagen = Sprite2D.new()
	var textura = load(ruta_imagen)
	sprite_imagen.texture = textura
	
	# Obtener el tamaño de la ventana
	var ventana = get_viewport_rect().size
	
	# Calcular la escala para mantener las proporciones de forma dinámica
	var tamaño_deseado = Vector2(ventana.x * 0.25, ventana.y * 0.25)  # 25% del tamaño de pantalla
	var escala_x = tamaño_deseado.x / textura.get_width()
	var escala_y = tamaño_deseado.y / textura.get_height()
	var escala_final = min(escala_x, escala_y)  # Usar la escala más pequeña para mantener proporciones
	
	sprite_imagen.scale = Vector2(escala_final, escala_final)
	sprite_imagen.centered = true
	
	# Configurar el panel para contener la imagen correctamente
	var tamaño_imagen = textura.get_size() * escala_final
	panel.size = tamaño_imagen + Vector2(16, 16)  # 8px de borde en cada lado
	
	# Agregar la imagen al panel
	panel.add_child(sprite_imagen)
	sprite_imagen.position = panel.size / 2
	
	# Agregar el panel al contenedor
	contenedor.add_child(panel)
	panel.position = Vector2.ZERO
	
	# Colocar el contenedor centrado horizontalmente y arriba de los huecos
	contenedor.position = Vector2(ventana.x / 2 - panel.size.x / 2, ventana.y * 0.15)  # Centrado y arriba de los huecos
	
	add_child(contenedor)
	imagen_actual = contenedor  # Guardar referencia al contenedor
	
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
	
	# Calcular espaciado dinámico basado en el ancho de la pantalla
	var espacio_minimo = 120
	var espacio_dinamico = max(espacio_minimo, ventana.x * 0.08)  # 8% del ancho de pantalla
	var ancho_total = silabas.size() * espacio_dinamico
	var posicion_inicial_x = (ventana.x - ancho_total) / 2 + espacio_dinamico / 2
	
	# Calcular posiciones verticales centradas dinámicamente
	var posicion_huecos_y = ventana.y * 0.45  # 45% desde arriba
	var posicion_tarjetas_y = ventana.y * 0.75  # 75% desde arriba
	
	# Crea los huecos en orden (centrados)
	for i in range(silabas.size()):
		var hueco = escena_hueco.instantiate()
		hueco.hueco_id = i
		hueco.position = Vector2(posicion_inicial_x + i * espacio_dinamico, posicion_huecos_y)
		hueco.connect("tarjeta_colocada", Callable(self, "_on_tarjeta_colocada"))
		nodo_huecos.add_child(hueco)
		print("Hueco creado en posición: ", hueco.position)
	
	# Crea las tarjetas y las desordena (centradas abajo), asegurando que ninguna quede en su sitio
	var silabas_desordenadas = silabas.duplicate()
	var valido = false
	while not valido:
		silabas_desordenadas.shuffle()
		valido = true
		for i in range(silabas.size()):
			if silabas_desordenadas[i] == silabas[i]:
				valido = false
				break
	
	for i in range(silabas.size()):
		var idx = silabas.find(silabas_desordenadas[i])
		var tarjeta = escena_tarjeta.instantiate()
		tarjeta.setup(silabas_desordenadas[i], idx)
		tarjeta.position = Vector2(posicion_inicial_x + i * espacio_dinamico, posicion_tarjetas_y)
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
			correct_attempts += 1
			total_attempts += 1
			print("Tarjeta colocada correctamente. Total: ", tarjetas_colocadas, "/", total_tarjetas)
			
			# Play success sound
			if acierto_sound:
				print("Reproduciendo sonido de acierto")
				acierto_sound.play()
			else:
				print("ERROR: acierto_sound es null")
			
			# Show small completion animation
			animations.show_syllable_correct()
			# Verificar si se completó el nivel
			if tarjetas_colocadas == total_tarjetas:
				print("¡Nivel completado!")
				# Show full game completion animation with stars
				animations.show_game_completion(100, 3, total_attempts, correct_attempts)
				# Wait for the animation to finish before continuing
				await animations.game_completion_finished
				# Then change to a new word
				seleccionar_palabra_aleatoria()
		else:
			# Devolver la tarjeta a su posición original inmediatamente
			tarjeta.position = tarjeta.start_position
			tarjeta.can_drag = true
			hueco.liberar_tarjeta()
			
			# Play error sound
			if error_sound:
				print("Reproduciendo sonido de error")
				error_sound.play()
			else:
				print("ERROR: error_sound es null")
			
			# Colocación incorrecta: poner todos los huecos en rojo
			for h in nodo_huecos.get_children():
				if h.has_method("mostrar_error_rojo"):
					h.mostrar_error_rojo()
			vidas -= 1
			total_attempts += 1
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
	
	# Reposicionar la imagen actual si existe
	if imagen_actual:
		var ventana = get_viewport_rect().size
		# Obtener el panel del contenedor para calcular el tamaño
		var panel = imagen_actual.get_child(0) if imagen_actual.get_child_count() > 0 else null
		if panel:
			imagen_actual.position = Vector2(ventana.x / 2 - panel.size.x / 2, ventana.y * 0.15)
		else:
			imagen_actual.position = Vector2(ventana.x / 2, ventana.y * 0.15)
	
	# Reposicionar huecos y tarjetas si hay una partida activa
	if palabra_actual != "" and palabras.has(palabra_actual):
		reposicionar_elementos_juego()
	
	centrar_vidas()

func centrar_vidas():
	if has_node("Vidas"):
		var ventana = get_viewport_rect().size
		var vidas = $Vidas
		if vidas.has_node("HBoxContainer"):
			var hbox = vidas.get_node("HBoxContainer")
			vidas.position = Vector2(ventana.x / 2 - hbox.size.x / 2, ventana.y * 0.05)
		else:
			vidas.position = Vector2(ventana.x / 2, ventana.y * 0.05)

func ajustar_tira_silabas(num_huecos: int):
	if has_node("TiraSilabas"):
		var tira = $TiraSilabas
		var ventana = get_viewport_rect().size
		# Calcular ancho dinámico basado en el tamaño de pantalla
		var ancho_deseado = ventana.x * 0.6  # 60% del ancho de pantalla
		if tira.texture != null:
			var ancho_original = tira.texture.get_width()
			var escala_x = ancho_deseado / ancho_original
			tira.scale.x = escala_x
			print("Tira ajustada: ", num_huecos, " huecos, escala X: ", escala_x)
		else:
			print("[ADVERTENCIA] La textura de la tira de sílabas no está asignada.")

func reposicionar_elementos_juego():
	"""Reposicionar huecos y tarjetas cuando cambia el tamaño de pantalla"""
	if not palabra_actual or not palabras.has(palabra_actual):
		return
		
	var silabas = palabras[palabra_actual]["silabas"]
	var ventana = get_viewport_rect().size
	
	# Calcular espaciado dinámico
	var espacio_minimo = 120
	var espacio_dinamico = max(espacio_minimo, ventana.x * 0.08)
	var ancho_total = silabas.size() * espacio_dinamico
	var posicion_inicial_x = (ventana.x - ancho_total) / 2 + espacio_dinamico / 2
	
	# Posiciones verticales
	var posicion_huecos_y = ventana.y * 0.45
	var posicion_tarjetas_y = ventana.y * 0.75
	
	# Reposicionar huecos
	var huecos = nodo_huecos.get_children()
	for i in range(min(huecos.size(), silabas.size())):
		huecos[i].position = Vector2(posicion_inicial_x + i * espacio_dinamico, posicion_huecos_y)
	
	# Reposicionar tarjetas
	var tarjetas = nodo_tarjetas.get_children()
	for i in range(min(tarjetas.size(), silabas.size())):
		tarjetas[i].position = Vector2(posicion_inicial_x + i * espacio_dinamico, posicion_tarjetas_y)
		# Actualizar posición inicial para las tarjetas
		if tarjetas[i].has_method("set_start_position"):
			tarjetas[i].set_start_position(Vector2(posicion_inicial_x + i * espacio_dinamico, posicion_tarjetas_y))
