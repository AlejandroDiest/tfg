extends CharacterBody2D


const SPEED = 80.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	
	var direction_x := Input.get_axis("ui_left", "ui_right")

	if direction_x < 0:
		animated_sprite.flip_h = true
	elif direction_x > 0:
		animated_sprite.flip_h = false
	
	if direction_x:
		velocity.x = direction_x * SPEED
		
	else:
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	var direction_y := Input.get_axis("ui_up", "ui_down")
	

	
	if direction_y:
		velocity.y = direction_y * SPEED
		
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
