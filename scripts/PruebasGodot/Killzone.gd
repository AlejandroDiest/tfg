extends Area2D

@onready var game_manager =  get_tree().current_scene.get_node("%GameManager")

func _on_body_entered(_body: Node2D) -> void:
	GM.recibir_daño()
