extends Node2D

var vidas = 3
var corazones = []

func _ready():
	# Obtener el tamaño de la ventana
	var ventana = get_viewport_rect().size
	
	# Posicionar el contenedor en la parte superior central
	var container = $Container
	
	# Crear los corazones iniciales
	for i in range(vidas):
		var corazon = TextureRect.new()
		corazon.texture = preload("res://assets/corazon.png")
		corazon.custom_minimum_size = Vector2(40, 40)
		corazon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		container.add_child(corazon)
		corazones.append(corazon)
	
	# Ajustar el tamaño del contenedor basado en sus hijos
	await get_tree().process_frame
	container.position.x = (ventana.x - container.size.x) / 2
	container.position.y = 20  # 20 píxeles desde el borde superior

func actualizar_vidas(vidas_restantes):
	print("Actualizando vidas: ", vidas_restantes)
	vidas = vidas_restantes
	
	# Actualizar la visibilidad de los corazones
	for i in range(corazones.size()):
		corazones[i].visible = i < vidas
		print("Corazón ", i, " visible: ", corazones[i].visible) 