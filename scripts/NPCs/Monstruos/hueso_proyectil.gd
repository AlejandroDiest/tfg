extends Area2D

@export var velocidad: float = 150.0
@export var dano: int = 1

var direccion: Vector2 = Vector2.ZERO
var creador: Node2D = null

func configurar_proyectil(dir: Vector2, quien_lo_dispara: Node2D):
	direccion = dir.normalized()
	creador = quien_lo_dispara

func _ready():
	body_entered.connect(_on_body_entered)
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_destruir_por_tiempo)

func _destruir_por_tiempo():
	queue_free()

func _physics_process(delta):
	position += direccion * velocidad * delta

func _on_body_entered(body):
	if body.is_in_group("player"): 
		if body.has_method("recibir_daño"):
			body.recibir_daño(dano)
			queue_free()
			
	if body == creador:
		return
	queue_free()
