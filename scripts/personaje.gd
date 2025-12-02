extends CharacterBody2D


const SPEED = 80.0
@onready var sprite_personaje: AnimatedSprite2D = $SpritePersonaje

func _ready():
	print("--- SPAWN ---")
	print("Instrucción del GM: '", GM.destino_spawn_point, "'")
	
	if GM.destino_spawn_point != "":
		var spawn_marker = get_tree().get_root().find_child(GM.destino_spawn_point, true, false)
		
		if spawn_marker:
			print("Marcador encontrado en: ", spawn_marker.global_position)
			global_position = spawn_marker.global_position
		else:
			print("No existe ningún nodo llamado: '", GM.destino_spawn_point, "'")
			
		GM.destino_spawn_point = ""
	else:
		print("El GM no tiene ninguna instrucción (Spawn normal).")
	print("-------------------")
	
	
func _input(event):
	if event.is_action_pressed("escape"):
		GM.pausar_juego()
		
func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_vector.x < 0:
		sprite_personaje.flip_h = true
	elif input_vector.x > 0:
		sprite_personaje.flip_h = false
		
	if input_vector.length() > 0:
		velocity.x = input_vector.normalized().x * SPEED
		velocity.y = input_vector.normalized().y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED) 
		
	move_and_slide()
