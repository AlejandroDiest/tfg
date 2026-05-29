extends Area2D

@export var velocidad: float = 250.0
@export var dano: int = 1

var direccion: Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)

func _physics_process(delta):
	position += direccion * velocidad * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("¡Jugador golpeado!")
		
	queue_free()
