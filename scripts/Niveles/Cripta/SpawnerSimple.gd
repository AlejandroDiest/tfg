extends Node2D

@export var enemigo_scene: PackedScene

func _ready():
	spawnear()

func spawnear():
	if not enemigo_scene:
		return
		
	for marker in get_children():
		if marker is Marker2D:
			var enemigo = enemigo_scene.instantiate()
			enemigo.position = marker.position
			add_child(enemigo)
			
			marker.queue_free()
