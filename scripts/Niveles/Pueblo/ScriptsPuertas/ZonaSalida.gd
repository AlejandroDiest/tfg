extends Area2D

@export_file("*.tscn") var escena_destino


func _on_body_entered(body):
	if body.name == "Player": 
		cambiar_escena()
	else:
		print("NO ES EL JEUGADOR")

func cambiar_escena():
	if escena_destino:
	
		get_tree().change_scene_to_file(escena_destino)
	else:
		print("¡ERROR! No has puesto ninguna escena en la variable 'escena_destino'")
