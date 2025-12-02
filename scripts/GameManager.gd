extends Node

#region variables/constantes


const RUTA_GUARDADO = "user://savegame"
var partida_actual = 0
var destino_spawn_point: String = ""
var menu_pausa = preload("res://scenes/UI/MenuPausa.tscn")
var loading_screen_scene = preload("res://scenes/PantallaCarga.tscn") 
var datos_jugador: Dictionary = {
	"oro": 0,
	"vida_maxima": 3,
	"vida_actual": 3, 
}

#endregion

func on_ready():
	pass
	
#region cosas varias

func pausar_juego():
	
	var menu_instance = menu_pausa.instantiate()
	
	get_tree().root.add_child(menu_instance)
	
	get_tree().paused = true
	
func respawnear():
	datos_jugador.vida_actual = datos_jugador.vida_maxima
	
func recibir_daño():
	datos_jugador.vida_actual -= 1
	
func curar_personaje():
	datos_jugador.vida_actual = datos_jugador.vida_maxima
	
func add_oro():
	datos_jugador.oro += 1
	print(datos_jugador.oro)
#endregion

func cambiar_y_posicionar(nueva_escena_ruta: String, nombre_spawn_point: String):
	destino_spawn_point = nombre_spawn_point
	
	var loading_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_instance) 
	
	await loading_instance.aparecer()
	
	await get_tree().create_timer(1.0).timeout
	
	get_tree().change_scene_to_file(nueva_escena_ruta)
	
	await loading_instance.desaparecer()
	


	# --- SISTEMA DE GUARDADO ---

#region Guardado
func guardado_ruta_actual() -> String:
	return RUTA_GUARDADO + str(partida_actual) + ".json"
	
func guardar_partida():
	var archivo = FileAccess.open(guardado_ruta_actual(), FileAccess.WRITE)
	
	if FileAccess.get_open_error() != OK:
		print("Error al guardar en slot ", partida_actual)
		return
	
	var json_texto = JSON.stringify(datos_jugador)
	archivo.store_string(json_texto)
	print(" Guardado en Slot ", partida_actual)

func cargar_partida():
	
	if not FileAccess.file_exists(guardado_ruta_actual()):
		print("Slot ", partida_actual, " vacío. Iniciando datos por defecto.")
		resetear_datos()
		return
	
	var archivo = FileAccess.open(guardado_ruta_actual(), FileAccess.READ)
	var json_texto = archivo.get_as_text()
	var datos_guardados = JSON.parse_string(json_texto)
	
	if datos_guardados:
		datos_jugador = datos_guardados
		datos_jugador.oro = int(datos_jugador.oro)
		datos_jugador.vida_maxima = int(datos_jugador.vida_maxima)
		datos_jugador.vida_actual = datos_jugador.vida_maxima
		print(" Cargado Slot ", partida_actual)

func resetear_datos():
	datos_jugador = {
		"oro": 0,
		"vida_maxima": 3,
		"vida_actual": 2, 
	}

func existe_partida_en_slot(numero_slot: int) -> bool:
	var ruta = RUTA_GUARDADO + str(numero_slot) + ".json"
	return FileAccess.file_exists(ruta)
#endregion
