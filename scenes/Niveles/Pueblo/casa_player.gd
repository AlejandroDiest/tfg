extends Node2D
var jugador_cerca = false


func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("player"): 
		jugador_cerca = true
func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("player"): jugador_cerca = false
