extends Area2D

func _on_body_entered(body):
	# Si lo que choca contra el borde es nuestro jugador...
	if body.name == "Personaje":
		# Cabiamos la escena a la del pueblo
		get_tree().change_scene_to_file("res://scenes/Niveles/Pueblo/Pueblo.tscn")
