extends Area2D

@onready var game_manager: Node = %GameManager


func _on_body_entered(_body: Node2D) -> void:
	queue_free() 
	GM.add_oro()

	
