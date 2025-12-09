extends Area2D

signal interactuado

var jugador_objetivo: Node2D = null 
var dentro = false

func _ready():
	$Sprite2D.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Personaje":
		dentro = true
		jugador_objetivo = body 
		$Sprite2D.visible = true
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Personaje":
		dentro = false
		jugador_objetivo = null 
		$Sprite2D.visible = false

func _process(_delta):
	if dentro and jugador_objetivo != null:
		$Sprite2D.global_position = jugador_objetivo.global_position + Vector2(0, -30)
	
	if dentro and Input.is_action_just_pressed("interactuar"):
		interactuado.emit()
