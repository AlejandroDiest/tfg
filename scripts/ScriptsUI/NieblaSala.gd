extends Node2D

@onready var tapa_negra = $ColorRect

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Personaje" or body.is_in_group("Jugador"):
		desvelar_mapa_suave()
		$Area2D.set_deferred("monitoring", false)

func desvelar_mapa_suave():
	var tween = create_tween()
	tween.tween_property(tapa_negra, "modulate:a", 0.0, 1.0)
	tween.tween_callback(tapa_negra.queue_free)

# Función para ajustar el tamaño automáticamente
func ajustar_tamano(rectangulo_sala: Rect2):
	# 1. Ajustamos el cuadro negro
	$ColorRect.size = rectangulo_sala.size
	$ColorRect.position = rectangulo_sala.position
	
	# 2. Ajustamos el detector (Area2D)
	# Asumimos que el CollisionShape2D tiene un RectangleShape2D
	var collision = $Area2D/CollisionShape2D
	
	# Importante: Hacemos que la forma sea única para no deformar las otras nieblas
	if collision.shape is RectangleShape2D:
		collision.shape = collision.shape.duplicate() # Crear copia única
		collision.shape.size = rectangulo_sala.size
		
	# Centramos el collider (el rectángulo se dibuja desde la esquina, el collider desde el centro)
	collision.position = rectangulo_sala.position + (rectangulo_sala.size / 2)
