extends Area2D

@export_file("res://scenes/Niveles/Cementerio/Cementerio.tscn") var escena_destino: String


func _on_body_entered(body):
	if body.name == "Personaje": 
		cambiar_escena()
	else:
		print("NO ES EL JEUGADOR")

func cambiar_escena():
	if escena_destino:
		SceneManager.cambiar_y_posicionar(escena_destino)
	else:
		print("¡ERROR! No has puesto ninguna escena en la variable 'escena_destino'")
