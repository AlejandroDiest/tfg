extends Area2D

var puede_entrar = false

func _on_body_entered(body):
	if body.name == "Personaje":
			puede_entrar = true

func _on_body_exited(body):
	if body.name == "Personaje":
			puede_entrar = false
			
func _process(delta):
	if puede_entrar and Input.is_action_just_pressed("interactuar"):
		get_tree().change_scene_to_file("res://scenes/Niveles/Cripta/SalasCripta/SalasEspeciales/SalasFijas/SalaInicial.tscn")
