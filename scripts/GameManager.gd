extends Node

var destino_spawn_point: String = ""

var loading_screen_scene = preload("res://scenes/PantallaCarga.tscn") # <--- AJUSTA TU RUTA

func cambiar_y_posicionar(nueva_escena_ruta: String, nombre_spawn_point: String):
	destino_spawn_point = nombre_spawn_point
	
	var loading_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_instance) 
	
	await loading_instance.aparecer()
	
	get_tree().change_scene_to_file(nueva_escena_ruta)
	
	await get_tree().create_timer(1.0).timeout
	
	await loading_instance.desaparecer()
	
	# La instancia se borra sola con el queue_free() que pusimos en su script.
