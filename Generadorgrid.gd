extends Node2D

# --- TUS ESCENAS ---
@export var sala_inicial: PackedScene
@export var sala_escalera_boss: PackedScene
@export var salas_cripta: Array[PackedScene] # Arrastra Cripta 1, 2, 3, 4 aquí

# --- CONFIGURACIÓN ---
const GRID_ANCHO = 5
const GRID_ALTO = 5

# MATEMÁTICAS: 24 tiles * 32 px = 768 px
# Si tus tiles son de 16, cambia 32 por 16 (serían 384 px)
const PASO_GRID = 768 

var camino_generado = [] 

func _ready():
	# RenderingServer.set_default_clear_color(Color("#092437"))
	randomize()
	generar_nivel()

func generar_nivel():
	var exito = false
	var intentos = 0
	
	# Intentamos generar hasta que salga un camino válido
	while not exito and intentos < 100:
		exito = calcular_camino_serpiente()
		if not exito:
			intentos += 1
			print("Reintentando generación...")
	
	if exito:
		print("¡Nivel generado con éxito tras ", intentos, " intentos!")
		spawn_salas()
	else:
		print("ERROR: No se pudo generar un camino válido.")

func calcular_camino_serpiente() -> bool:
	camino_generado.clear()
	
	# 1. ELEGIR PARED DE INICIO
	var pared_inicio = randi() % 4 # 0:Norte, 1:Sur, 2:Este, 3:Oeste
	var cursor = Vector2i.ZERO
	var objetivo = "" 
	
	# Configuramos inicio y meta
	match pared_inicio:
		0: # Norte -> Meta Sur
			cursor = Vector2i(randi_range(0, GRID_ANCHO-1), 0)
			objetivo = "sur"
		1: # Sur -> Meta Norte
			cursor = Vector2i(randi_range(0, GRID_ANCHO-1), GRID_ALTO-1)
			objetivo = "norte"
		2: # Este -> Meta Oeste
			cursor = Vector2i(GRID_ANCHO-1, randi_range(0, GRID_ALTO-1))
			objetivo = "oeste"
		3: # Oeste -> Meta Este
			cursor = Vector2i(0, randi_range(0, GRID_ALTO-1))
			objetivo = "este"
			
	camino_generado.append(cursor)
	
	# 2. CAMINAR
	var llegado = false
	
	while not llegado:
		var movimientos_validos = []
		var direcciones = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
		for dir in direcciones:
			var nueva_pos = cursor + dir
			
			# Check Límites Grid 5x5
			if nueva_pos.x < 0 or nueva_pos.x >= GRID_ANCHO or nueva_pos.y < 0 or nueva_pos.y >= GRID_ALTO:
				continue
			
			# Check Auto-choque (No volver por donde vinimos)
			if nueva_pos in camino_generado:
				continue
				
			movimientos_validos.append(nueva_pos)
		
		# Si no hay salida, hemos fallado
		if movimientos_validos.size() == 0:
			return false
			
		# Avanzamos
		cursor = movimientos_validos.pick_random()
		camino_generado.append(cursor)
		
		# Check Meta
		if objetivo == "sur" and cursor.y == GRID_ALTO - 1: llegado = true
		elif objetivo == "norte" and cursor.y == 0: llegado = true
		elif objetivo == "oeste" and cursor.x == 0: llegado = true
		elif objetivo == "este" and cursor.x == GRID_ANCHO - 1: llegado = true
		print(camino_generado)
	return true

func spawn_salas():
	# Limpiar pruebas anteriores
	for child in get_children():
		child.queue_free()
		
	# Colocar las escenas
	for i in range(camino_generado.size()):
		var coord = camino_generado[i]
		var instancia = null
		
		if i == 0:
			instancia = sala_inicial.instantiate()

		elif i == camino_generado.size() - 1:
			instancia = sala_escalera_boss.instantiate()
		else:
			instancia = salas_cripta.pick_random().instantiate()
			
		# Posicionar
		instancia.position = Vector2(coord.x * PASO_GRID, coord.y * PASO_GRID)
		add_child(instancia)
		
		# (Opcional) Debug visual para ver coordenadas
		var label = Label.new()
		label.text = str(coord)
		label.scale = Vector2(3,3)
		instancia.add_child(label)
		
#region grid y camino debug y camara

	var linea_debug = Line2D.new()
	linea_debug.width = 40.0
	linea_debug.default_color = Color.RED
	linea_debug.z_index = 100  # <--- ESTO ES LA CLAVE: Lo dibuja encima de las salas
	
	# Añadimos los puntos
	for coord in camino_generado:
		# Como tus salas están centradas, el punto es simplemente coord * PASO
		linea_debug.add_point(Vector2(coord) * PASO_GRID)
		
	add_child(linea_debug)
	var grosor_grid = 20.0
	var color_grid = Color(0, 1, 0, 0.3)
	var z_index_grid = 90 # Alto, pero menos que la línea roja (100) para que el camino destaque
	var mitad_paso = PASO_GRID / 2.0

	# 1. Crear líneas Verticales
	for x in range(GRID_ANCHO + 1):
		var linea = Line2D.new()
		linea.width = grosor_grid
		linea.default_color = color_grid
		linea.z_index = z_index_grid
		
		var pos_x = (x * PASO_GRID) - mitad_paso
		# Punto arriba
		linea.add_point(Vector2(pos_x, -mitad_paso))
		# Punto abajo
		linea.add_point(Vector2(pos_x, (GRID_ALTO * PASO_GRID) - mitad_paso))
		
		add_child(linea)

	# 2. Crear líneas Horizontales
	for y in range(GRID_ALTO + 1):
		var linea = Line2D.new()
		linea.width = grosor_grid
		linea.default_color = color_grid
		linea.z_index = z_index_grid
		
		var pos_y = (y * PASO_GRID) - mitad_paso
		# Punto izquierda
		linea.add_point(Vector2(-mitad_paso, pos_y))
		# Punto derecha
		linea.add_point(Vector2((GRID_ANCHO * PASO_GRID) - mitad_paso, pos_y))
		
		add_child(linea)
		
		# ... (código anterior de salas, línea roja y grid verde) ...

	# --- CÁMARA CENTRADA EN EL GRID (5x5) ---
	var cam = Camera2D.new()
	cam.set_script(load("res://scripts/CamaraDebug.gd")) 
	cam.enabled = true
	
	# Ajusta el zoom inicial para ver casi todo el mapa
	cam.zoom = Vector2(0.08, 0.08) 
	
	# CALCULAR EL CENTRO MATEMÁTICO
	# En un grid de 0 a 4 (5 casillas), el centro es el índice 2.
	# Fórmula: (Ancho - 1) / 2.0
	var centro_x = (GRID_ANCHO - 1) / 2.0
	var centro_y = (GRID_ALTO - 1) / 2.0
	
	# Convertimos coordenadas de grid a pixeles
	# Como tus tiles tienen el pivote en el centro, la posición es directa:
	cam.position = Vector2(centro_x, centro_y) * PASO_GRID
	
	# Añadimos la cámara al Generador (no a una sala)
	add_child(cam)
#endregion
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		print("--- REINICIANDO ESCENA ---")
		get_tree().reload_current_scene()
