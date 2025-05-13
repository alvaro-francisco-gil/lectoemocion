extends Node2D

var vidas = 3
var corazones = []

func _ready():
	# Posicionar el nodo en la parte superior de la pantalla
	position = Vector2(20, 20)  # 20 píxeles desde el borde superior izquierdo
	
	# Crear los corazones iniciales
	for i in range(vidas):
		var corazon = ColorRect.new()
		corazon.size = Vector2(40, 40)
		corazon.position = Vector2(i * 50, 0)  # Espaciado de 50 píxeles entre corazones
		corazon.color = Color(1, 0, 0, 1)  # Rojo sólido
		
		# Crear la forma del corazón usando un Polygon2D
		var heart_shape = Polygon2D.new()
		var points = PackedVector2Array([
			Vector2(20, 10),  # Punto superior
			Vector2(10, 20),  # Izquierda
			Vector2(20, 30),  # Abajo
			Vector2(30, 20),  # Derecha
			Vector2(20, 10)   # Volver al inicio
		])
		heart_shape.polygon = points
		heart_shape.color = Color(1, 0, 0, 1)
		heart_shape.position = Vector2(0, 0)
		
		corazon.add_child(heart_shape)
		add_child(corazon)
		corazones.append(corazon)
		print("Corazón creado en posición: ", corazon.position)

func actualizar_vidas(vidas_restantes):
	print("Actualizando vidas: ", vidas_restantes)
	vidas = vidas_restantes
	
	# Actualizar la visibilidad de los corazones
	for i in range(corazones.size()):
		corazones[i].visible = i < vidas
		print("Corazón ", i, " visible: ", corazones[i].visible) 