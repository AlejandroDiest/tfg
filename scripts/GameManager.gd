extends Node

#region VARIABLES Y CONSTANTES

const RUTA_GUARDADO = "user://savegame"
var partida_actual = 0

var destino_spawn_point: String = ""
var nivel_pueblo_cache: PackedScene = null
var nivel_cripta_cache: PackedScene = null

var menu_pausa = preload("res://scenes/UI/Menus/MenuPausa.tscn")
var loading_screen_scene = preload("res://scenes/UI/PantallasCarga/PantallaCarga.tscn") 


var datos_jugador: Dictionary = {
	"oro": 0,
	"vida_maxima": 3,
	"vida_actual": 3, 
}

#endregion

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

#region GESTIÓN DE LA MOCHILA (NUEVO)

func ir_al_nivel_rapido(nombre_nivel: String, nombre_spawn: String):
	
	destino_spawn_point = nombre_spawn
	
	var escena_destino: PackedScene = null
	
	match nombre_nivel:
		"Pueblo": escena_destino = nivel_pueblo_cache
		"Cripta": escena_destino = nivel_cripta_cache
	
	if escena_destino != null:
		print("Viajando rápido a: ", nombre_nivel)
		

		get_tree().change_scene_to_packed(escena_destino)
		
	else:
		print("ERROR CRÍTICO: El nivel ", nombre_nivel, " no está en la mochila (es null).")
		print("Intentando carga de emergencia tradicional...")

#endregion

#region COSAS VARIAS (Gameplay)
func aumentar_vida_maxima():
	datos_jugador.vida_maxima += 1
	datos_jugador.vida_actual = datos_jugador.vida_maxima 
func pausar_juego():
	var menu_instance = menu_pausa.instantiate()
	get_tree().root.add_child(menu_instance)
	get_tree().paused = true
	
func respawnear():
	datos_jugador.vida_actual = datos_jugador.vida_maxima
	
func recibir_daño():
	datos_jugador.vida_actual -= 1
	if datos_jugador.vida_actual < 0: datos_jugador.vida_actual = 0
	
func curar_personaje():
	datos_jugador.vida_actual = datos_jugador.vida_maxima
	
func add_oro():
	datos_jugador.oro += 1
	print("Oro actual: ", datos_jugador.oro)
#endregion

#region SISTEMA ANTIGUO (Carga lenta con pantalla) 

func cambiar_y_posicionar(nueva_escena_ruta: String, nombre_spawn_point: String):
	destino_spawn_point = nombre_spawn_point
	
	var loading_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_instance) 
	
	await loading_instance.aparecer()
	await get_tree().create_timer(1.0).timeout 
	
	get_tree().change_scene_to_file(nueva_escena_ruta)
	
	await loading_instance.desaparecer()
#endregion

#region SISTEMA DE GUARDADO (SAVE/LOAD)

func guardado_ruta_actual() -> String:
	return RUTA_GUARDADO + str(partida_actual) + ".json"
	
func guardar_partida():
	var archivo = FileAccess.open(guardado_ruta_actual(), FileAccess.WRITE)
	
	if FileAccess.get_open_error() != OK:
		print("Error al guardar en slot ", partida_actual)
		return
	
	var json_texto = JSON.stringify(datos_jugador)
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
		datos_jugador = datos_guardados
		datos_jugador.oro = int(datos_jugador.oro)
		datos_jugador.vida_maxima = int(datos_jugador.vida_maxima)
		datos_jugador.vida_actual = int(datos_jugador.vida_actual)
		print("Datos cargados del Slot ", partida_actual)

func resetear_datos():
	datos_jugador = {
		"oro": 0,
		"vida_maxima": 3,
		"vida_actual": 3, 
	}

func existe_partida_en_slot(numero_slot: int) -> bool:
	var ruta = RUTA_GUARDADO + str(numero_slot) + ".json"
	return FileAccess.file_exists(ruta)
#endregion

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pausar_juego()
