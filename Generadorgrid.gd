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
			# print("Reintentando generación...")
	
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
			# --- AÑADE ESTO AQUÍ ---
			print("Poniendo cámara en la sala inicial: ", coord)
			var camara_debug = Camera2D.new()
			camara_debug.enabled = true
			
			# Zoom 0.2 para verlo TODO desde muy lejos (Vista de pájaro)
			# Si quieres verla de cerca, pon Vector2(1, 1)
			camara_debug.zoom = Vector2(0.1, 0.1) 
			
			instancia.add_child(camara_debug)
			# -----------------------
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
