extends Node2D

@export var enemigo_scene: PackedScene

func _ready():
	# YA NO necesitamos esperar al process_frame.
	# Las coordenadas locales existen desde el principio.
	spawnear()

func spawnear():
	if not enemigo_scene:
		return
		
	for marker in get_children():
		if marker is Marker2D:
			var enemigo = enemigo_scene.instantiate()
			
			# TRUCO PRO:
			# Copiamos la posición LOCAL, no la global.
			# Como ambos están dentro del mismo contenedor, la posición es idéntica.
			enemigo.position = marker.position
			
			# Añadimos el enemigo
			add_child(enemigo)
			
			# Borramos el marcador
			marker.queue_free()
