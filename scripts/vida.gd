extends Area2D

	
func _on_body_entered(_body: Node2D) -> void:
	GM.aumentar_vida_maxima()
	queue_free()
