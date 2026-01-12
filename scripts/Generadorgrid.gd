extends Node2D

#region Configuración
@export var sala_inicial: PackedScene
@export var sala_escalera_boss: PackedScene
@export var salas_cripta: Array[PackedScene] 
@export var salas_tesoro: Array[PackedScene] 
@export var salas_cruce: Array[PackedScene]

const GRID_ANCHO = 5
const GRID_ALTO = 5
const PASO_GRID = 768 

var camino_generado = [] 
var ramas_generadas = [] 
#endregion

func _ready():
	RenderingServer.set_default_clear_color(Color("#092437"))
	randomize()
	generar_nivel()

func generar_nivel():
	var exito = false
	var intentos = 0
	
	while not exito and intentos < 100:
		exito = calcular_camino_serpiente()
		if not exito:
			intentos += 1
			print("Reintentando... (", intentos, ")")
	
	if exito:
		generar_ramas() 
		spawn_salas()
		_dibujar_debug()
	else:
		print("ERROR: Fallo en generación.")


func calcular_camino_serpiente() -> bool:
	camino_generado.clear()
	ramas_generadas.clear()
	
	var pared_inicio = randi() % 4 
	var cursor = Vector2i.ZERO
	var objetivo = "" 
	var dir_prohibida = Vector2i.ZERO 
	
	match pared_inicio:
		0: 
			cursor = Vector2i(randi_range(0, GRID_ANCHO-1), 0)
			objetivo = "sur"; dir_prohibida = Vector2i.UP 
		1: 
			cursor = Vector2i(randi_range(0, GRID_ANCHO-1), GRID_ALTO-1)
			objetivo = "norte"; dir_prohibida = Vector2i.DOWN 
		2: 
			cursor = Vector2i(GRID_ANCHO-1, randi_range(0, GRID_ALTO-1))
			objetivo = "oeste"; dir_prohibida = Vector2i.RIGHT 
		3: 
			cursor = Vector2i(0, randi_range(0, GRID_ALTO-1))
			objetivo = "este"; dir_prohibida = Vector2i.LEFT 
			
	camino_generado.append(cursor)
	
	var llegado = false
	var seguridad = 0 
	
	while not llegado:
		seguridad += 1; if seguridad > 100: return false 
		
		var validos = []
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			if dir == dir_prohibida: continue
			var pos = cursor + dir
			if not es_en_grid(pos): continue
			if pos in camino_generado: continue
			validos.append(pos)
		
		if validos.is_empty(): return false
		cursor = validos.pick_random()
		camino_generado.append(cursor)
		
		if objetivo == "sur" and cursor.y == GRID_ALTO - 1: llegado = true
		elif objetivo == "norte" and cursor.y == 0: llegado = true
		elif objetivo == "oeste" and cursor.x == 0: llegado = true
		elif objetivo == "este" and cursor.x == GRID_ANCHO - 1: llegado = true
			
	return (camino_generado.size() >= 8 and camino_generado.size() <= 10)


func generar_ramas():
	ramas_generadas.clear()
	
	var cantidad_objetivo = randi_range(1, 2)
	
	if cantidad_objetivo == 0:
		print("Sin tesoros")
		return
	
	var mapa_ocupado = camino_generado.duplicate()
	var intentos_totales = 0
	
	while ramas_generadas.size() < cantidad_objetivo and intentos_totales < 50:
		intentos_totales += 1
		var candidatos = []
		

		for i in range(1, camino_generado.size() - 1):
			var cursor = camino_generado[i]
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var posible_rama = cursor + dir
				
				if posible_rama in mapa_ocupado: continue
				
				
				if contar_vecinos(posible_rama, mapa_ocupado) == 1:
					candidatos.append(posible_rama)
		
		if candidatos.is_empty():
			print("No caben más ramas. Se generaron: ", ramas_generadas.size())
			break
			
		var elegida = candidatos.pick_random()
		ramas_generadas.append(elegida)
		mapa_ocupado.append(elegida)
		
	print("Ramas generadas: ", ramas_generadas.size(), " / Objetivo: ", cantidad_objetivo)


func spawn_salas():
	for child in get_children():
		if child is Camera2D: continue
		if child is CanvasModulate: continue
		
		child.queue_free()


	var mapa_total = camino_generado + ramas_generadas
	
	for i in range(camino_generado.size()):
		var coord = camino_generado[i]
		var tipo = null
		
		if i == 0: tipo = sala_inicial
		elif i == camino_generado.size() - 1: tipo = sala_escalera_boss
		else: tipo = salas_cripta.pick_random() 
		
		instanciar_sala(coord, tipo, mapa_total)


	for coord in ramas_generadas:
		var tipo = salas_cripta.pick_random() 
		if salas_tesoro.size() > 0:
			tipo = salas_tesoro.pick_random()
			
		instanciar_sala(coord, tipo, mapa_total)

func instanciar_sala(coord: Vector2i, packed_scene: PackedScene, mapa_referencia: Array):
	var conexiones_necesarias = calcular_conexiones(coord, mapa_referencia)
	var instancia = null
	
	if packed_scene in salas_cripta or packed_scene in salas_tesoro:
		var candidatas = []
		if packed_scene in salas_tesoro: candidatas = salas_tesoro.duplicate()
		else: candidatas = salas_cripta.duplicate() 
		
		candidatas.shuffle()
		for opcion in candidatas:
			var intento = opcion.instantiate()
			if intento.has_method("encaja_con"):
				if intento.encaja_con(conexiones_necesarias):
					instancia = intento; break
			intento.queue_free()
	else:
		instancia = packed_scene.instantiate() 


	if instancia == null and salas_cruce.size() > 0:
		var candidatas_cruce = salas_cruce.duplicate()
		candidatas_cruce.shuffle()
		
		for opcion in candidatas_cruce:
			var intento = opcion.instantiate()
			if intento.has_method("encaja_con"):
				if intento.encaja_con(conexiones_necesarias):
					instancia = intento 
					break
			intento.queue_free()

	if instancia == null: 
		instancia = packed_scene.instantiate()
		print("AVISO: Forzando sala genérica en ", coord, ". Faltan piezas en tu inventario para: ", conexiones_necesarias)


	instancia.position = Vector2(coord.x * PASO_GRID, coord.y * PASO_GRID)
	add_child(instancia)
	
	if instancia.has_method("configurar_tapones"):
		instancia.configurar_tapones(conexiones_necesarias)
		
	var l = Label.new(); l.text = str(coord); l.scale = Vector2(3,3); l.z_index=200
	instancia.add_child(l)
	
#region utilidades


func es_en_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_ANCHO and pos.y >= 0 and pos.y < GRID_ALTO

func calcular_conexiones(coord: Vector2i, mapa: Array) -> Array[Vector2]:
	var conexiones: Array[Vector2] = []
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if (coord + dir) in mapa:
			conexiones.append(Vector2(dir))
	return conexiones

func contar_vecinos(coord: Vector2i, mapa: Array) -> int:
	var cuenta = 0
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if (coord + dir) in mapa:
			cuenta += 1
	return cuenta
#endregion

func _dibujar_debug():
#region dibujo

	# 1. CAMINO PRINCIPAL (Rojo - Una sola línea continua)
	var linea_camino = Line2D.new()
	linea_camino.width = 40.0
	linea_camino.default_color = Color.RED
	linea_camino.z_index = 100 
	for coord in camino_generado:
		linea_camino.add_point(Vector2(coord) * PASO_GRID)
	add_child(linea_camino)
	
	# 2. RAMAS (Amarillo - Líneas INDEPENDIENTES)
	for rama in ramas_generadas:
		# Buscamos al vecino (padre) para conectar solo con él
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var vecino = rama + dir
			# Si el vecino es parte del camino principal, dibujamos la línea
			if vecino in camino_generado:
				var linea_rama = Line2D.new() # <--- ¡Nueva línea para cada rama!
				linea_rama.width = 30.0
				linea_rama.default_color = Color.YELLOW
				linea_rama.z_index = 101
				
				linea_rama.add_point(Vector2(vecino) * PASO_GRID)
				linea_rama.add_point(Vector2(rama) * PASO_GRID)
				add_child(linea_rama)
				# Break para que no dibuje más de una línea si hubiera dudas
				break 

	# 3. GRID (Verde - Igual que antes)
	var grosor = 20.0; var col = Color(0, 1, 0, 0.3); var z = 90; var mitad = PASO_GRID / 2.0
	for x in range(GRID_ANCHO + 1):
		var l = Line2D.new(); l.width = grosor; l.default_color = col; l.z_index = z
		var px = (x * PASO_GRID) - mitad
		l.add_point(Vector2(px, -mitad)); l.add_point(Vector2(px, (GRID_ALTO * PASO_GRID) - mitad))
		add_child(l)
	for y in range(GRID_ALTO + 1):
		var l = Line2D.new(); l.width = grosor; l.default_color = col; l.z_index = z
		var py = (y * PASO_GRID) - mitad
		l.add_point(Vector2(-mitad, py)); l.add_point(Vector2((GRID_ANCHO * PASO_GRID) - mitad, py))
		add_child(l)
#endregion

	# 4. CÁMARA
	if not has_node("CamaraDebug"):
		var cam = Camera2D.new(); cam.name = "CamaraDebug"
		if ResourceLoader.exists("res://scripts/CamaraDebug.gd"): cam.set_script(load("res://scripts/CamaraDebug.gd"))
		cam.enabled = true; cam.zoom = Vector2(0.1, 0.1)
		cam.position = Vector2((GRID_ANCHO-1)/2.0, (GRID_ALTO-1)/2.0) * PASO_GRID
		add_child(cam)
		
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		generar_nivel()
