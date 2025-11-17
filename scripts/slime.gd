extends Node2D

const SPEED = 40
@onready var ray_cast_izq: RayCast2D = $RayCastIzq
@onready var ray_cast_dcha: RayCast2D = $RayCastDcha
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var direccion = 1
func _process(delta):
	
	if ray_cast_dcha.is_colliding():
		direccion = -1
		animated_sprite.flip_h = true
	if ray_cast_izq.is_colliding():
		direccion = 1
		animated_sprite.flip_h = false
	position.x += SPEED * delta * direccion
