extends Node

var nivel_pueblo_cache: PackedScene = null
var nivel_cripta_cache: PackedScene = null
var nivel_cementerio_cache: PackedScene = null

var loading_screen_scene = preload("res://scenes/UI/PantallasCarga/PantallaCarga.tscn") 
var destino_spawn_point: String = ""
var viajando: bool = false
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func ir_al_nivel_rapido(nombre_nivel: String, nombre_spawn: String):
	destino_spawn_point = nombre_spawn
	var escena_destino: PackedScene = null
	
	match nombre_nivel:
		"Pueblo": escena_destino = nivel_pueblo_cache
		"Cripta": escena_destino = nivel_cripta_cache
		"Cementerio": escena_destino  = nivel_cementerio_cache
	
	if escena_destino != null:
		print("Viajando rápido a: ", nombre_nivel)
		get_tree().change_scene_to_packed(escena_destino)
	else:
		print("ERROR CRÍTICO: El nivel ", nombre_nivel, " no está en la mochila.")

func cambiar_y_posicionar(nueva_escena_ruta: String, nombre_spawn: String = ""):
	if viajando:
			return
	destino_spawn_point = nombre_spawn
	viajando = true
	var loading_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_instance) 
	
	await loading_instance.aparecer()
	await get_tree().create_timer(1.0).timeout 
	
	get_tree().change_scene_to_file(nueva_escena_ruta)
	get_tree().paused = false
	await loading_instance.desaparecer()
	loading_instance.queue_free()
	viajando = false
