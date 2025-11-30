extends CharacterBody2D

const SPEED = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_vector.x < 0:
		animated_sprite.flip_h = true
	elif input_vector.x > 0:
		animated_sprite.flip_h = false
		
	if input_vector.length() > 0:
		velocity.x = input_vector.normalized().x * SPEED
		velocity.y = input_vector.normalized().y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED) 
		
	move_and_slide()
