extends Node2D

@onready var tapa_negra = $ColorRect

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	print("ALGO ha tocado la niebla: ", body.name)
	
	if body.name == "Personaje" or body.is_in_group("Jugador"):
		print("¡Es el jugador! Borrando niebla...")
		desvelar_mapa_suave() 
		queue_free()

func desvelar_mapa_suave():
	var tween = create_tween()
	tween.tween_property(tapa_negra, "modulate:a", 0.0, 1.0)
	tween.tween_callback(tapa_negra.queue_free)


func ajustar_tamano(rectangulo_sala: Rect2):
	$ColorRect.size = rectangulo_sala.size
	$ColorRect.position = rectangulo_sala.position

	var collision = $Area2D/CollisionShape2D
	
	if collision.shape is RectangleShape2D:
		collision.shape = collision.shape.duplicate() 
		collision.shape.size = rectangulo_sala.size
		
	collision.position = rectangulo_sala.position + (rectangulo_sala.size / 2)
