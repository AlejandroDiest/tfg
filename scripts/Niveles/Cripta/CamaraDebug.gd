extends Camera2D

# Velocidad muy alta porque tus salas miden 768 pixeles cada una
@export var velocidad_movimiento = 2000
@export var velocidad_zoom = Vector2(0.02, 0.02)

func _process(delta):
	# Movimiento con WASD o Flechas
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Movemos la cámara
	position += direccion * velocidad_movimiento * delta

func _unhandled_input(event):
	# Zoom con la Rueda del Ratón
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += velocidad_zoom # Acercar
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= velocidad_zoom # Alejar
			
		# Limitamos para que no se invierta la imagen ni te acerques demasiado
		zoom.x = clamp(zoom.x, 0.05, 2.0)
		zoom.y = clamp(zoom.y, 0.05, 2.0)
