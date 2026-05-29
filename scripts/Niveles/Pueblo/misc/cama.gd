extends Node2D

var pantalla_dormir_escena = preload("res://scenes/UI/PantallasCarga/PantallaDormir.tscn")

func _ready():
	actualizar_cama(GameManager.es_de_noche)
	if not $ZonaInteraccion.interactuado.is_connected(_on_interactuar_cama):
		$ZonaInteraccion.interactuado.connect(_on_interactuar_cama)

func _on_interactuar_cama():
	if GameManager.es_de_noche:
		iniciar_sueno()
	else:
		print("Aún es de día, no tienes sueño.")

func actualizar_cama(es_noche: bool):
	if es_noche:
		$ZonaInteraccion.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		$ZonaInteraccion.process_mode = Node.PROCESS_MODE_DISABLED
		$ZonaInteraccion.dentro = false
		var sprite_interaccion = $ZonaInteraccion.get_node_or_null("Sprite2D")
		if sprite_interaccion:
			sprite_interaccion.visible = false
			
func iniciar_sueno():
	var pantalla = pantalla_dormir_escena.instantiate()
	get_tree().root.add_child(pantalla)
	
	await pantalla.aparecer()
	
	GameManager.curar_personaje()
	
	var jugador = get_tree().get_first_node_in_group("player")
	var ruta_mapa = get_tree().current_scene.scene_file_path
	var pos_jugador = Vector2.ZERO
	
	if jugador:
		pos_jugador = jugador.global_position
		

	SaveManager.guardar_partida(ruta_mapa, pos_jugador)
	
	await get_tree().create_timer(1.0).timeout
	
	GameManager.es_de_noche = false
	GameManager.emit_signal("cambio_horario", false) 
	
	await pantalla.desaparecer()
	
	pantalla.queue_free()
