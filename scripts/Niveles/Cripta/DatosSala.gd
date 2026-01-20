extends Node2D


@export var puertas_disponibles: Array[Vector2] = []

@export_group("Tapones Visuales")
@export var tapon_norte: Node2D
@export var tapon_sur: Node2D
@export var tapon_este: Node2D
@export var tapon_oeste: Node2D


func encaja_con(puertas_necesarias: Array) -> bool:
	for puerta in puertas_necesarias:
		if not puertas_disponibles.has(puerta):
			return false
	return true

func configurar_tapones(puertas_necesarias: Array):
	# Norte (0, -1)
	if tapon_norte:
	
		if puertas_necesarias.has(Vector2(0, -1)):
			tapon_norte.queue_free()
		else:
			tapon_norte.visible = true 

	# Sur (0, 1)
	if tapon_sur:
		if puertas_necesarias.has(Vector2(0, 1)):
			tapon_sur.queue_free()
		else:
			tapon_sur.visible = true

	# Este (1, 0)
	if tapon_este:
		if puertas_necesarias.has(Vector2(1, 0)):
			tapon_este.queue_free()
		else:
			tapon_este.visible = true

	# Oeste (-1, 0)
	if tapon_oeste:
		if puertas_necesarias.has(Vector2(-1, 0)):
			tapon_oeste.queue_free()
		else:
			tapon_oeste.visible = true
