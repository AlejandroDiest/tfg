extends Camera2D

@export var velocidad_movimiento = 2000
@export var velocidad_zoom = Vector2(0.02, 0.02)

func _process(delta):
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += direccion * velocidad_movimiento * delta

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += velocidad_zoom 
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= velocidad_zoom 
			
		zoom.x = clamp(zoom.x, 0.05, 2.0)
		zoom.y = clamp(zoom.y, 0.05, 2.0)
