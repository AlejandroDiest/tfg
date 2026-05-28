extends Node

const RUTA_GUARDADO = "user://savegame"
var partida_actual = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- LÓGICA DE GUARDADO MEJORADA ---
func guardar_partida():
	var archivo = FileAccess.open(guardado_ruta_actual(), FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		print("Error al guardar en slot ", partida_actual)
		return
		
	GameManager.datos_jugador["inventario"] = _serializar_inventario()
	GameManager.datos_jugador["estado_vendedor"] = GameManager.estado_actual_vendedor
	GameManager.datos_jugador["estado_pueblo"] = GameManager.estado_pueblo
	
	var json_texto = JSON.stringify(GameManager.datos_jugador, "\t")
	archivo.store_string(json_texto)
	print("Partida guardada en Slot ", partida_actual)

func cargar_partida():
	if not FileAccess.file_exists(guardado_ruta_actual()):
		print("Slot ", partida_actual, " vacío. Iniciando datos por defecto.")
		resetear_datos()
		return
	
	var archivo = FileAccess.open(guardado_ruta_actual(), FileAccess.READ)
	var json_texto = archivo.get_as_text()
	var datos_guardados = JSON.parse_string(json_texto)
	
	if datos_guardados:
		GameManager.datos_jugador = datos_guardados
		
		GameManager.datos_jugador.oro = int(GameManager.datos_jugador.get("oro", 0))
		GameManager.datos_jugador.vida_maxima = int(GameManager.datos_jugador.get("vida_maxima", 3))
		GameManager.datos_jugador.vida_actual = int(GameManager.datos_jugador.get("vida_actual", 3))
		GameManager.datos_jugador["volumen_musica"] = float(datos_guardados.get("volumen_musica", 1.0))
		GameManager.datos_jugador["volumen_sfx"] = float(datos_guardados.get("volumen_sfx", 1.0))
		GameManager.estado_actual_vendedor = int(datos_guardados.get("estado_vendedor", 0))
		GameManager.estado_pueblo = int(datos_guardados.get("estado_pueblo", 0))
		
		var bus_musica = AudioServer.get_bus_index("Musica")
		var vol_musica = GameManager.datos_jugador.get("volumen_musica", 1.0)
		AudioServer.set_bus_volume_db(bus_musica, linear_to_db(vol_musica))
		
		var bus_sfx = AudioServer.get_bus_index("SFX")
		var vol_sfx = GameManager.datos_jugador.get("volumen_sfx", 1.0)
		AudioServer.set_bus_volume_db(bus_sfx, linear_to_db(vol_sfx))
		
		if datos_guardados.has("inventario"):
			_deserializar_inventario(datos_guardados["inventario"])
		else:
			GameManager.inventario_recurso.reset()
			
		print("Datos cargados del Slot ", partida_actual)

func resetear_datos():
	GameManager.datos_jugador = {
		"oro": 0,
		"vida_maxima": 3,
		"vida_actual": 3,
		"dano": 0,
		"equipamiento": {},
		"volumen_musica": 1.0, 
		"volumen_sfx": 1.0
	}
	
	GameManager.estado_actual_vendedor = 0
	GameManager.estado_pueblo = 0        
	
	if GameManager.inventario_recurso:
		GameManager.inventario_recurso.reset()

func guardado_ruta_actual() -> String:
	return RUTA_GUARDADO + str(partida_actual) + ".json"

func existe_partida_en_slot(numero_slot: int) -> bool:
	var ruta = RUTA_GUARDADO + str(numero_slot) + ".json"
	return FileAccess.file_exists(ruta)

# --- SERIALIZACIÓN (Intacta, ya era perfecta) ---
func _serializar_inventario() -> Array:
	var lista_guardado = []
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null:
			var datos_slot = {
				"ruta_item": slot.item.resource_path,
				"cantidad": slot.cantItem
			}
			lista_guardado.append(datos_slot)
		else:
			lista_guardado.append(null)
	return lista_guardado
	
func _deserializar_inventario(datos_cargados: Array):
	GameManager.inventario_recurso.reset()
	for i in range(datos_cargados.size()):
		var datos = datos_cargados[i]
		if datos != null and i < GameManager.inventario_recurso.inventario.size():
			if ResourceLoader.exists(datos["ruta_item"]):
				var item_cargado = load(datos["ruta_item"])
				GameManager.inventario_recurso.inventario[i].item = item_cargado
				GameManager.inventario_recurso.inventario[i].cantItem = int(datos["cantidad"])
	GameManager.inventario_recurso.update_ui.emit()
