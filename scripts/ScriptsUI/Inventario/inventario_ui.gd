extends NinePatchRect

var abierto = false


func _ready():
	cerrar()
	
	
func _process(delta):
	if Input.is_action_just_pressed("I"):
		if abierto:
			cerrar()
		else:
			abrir()
		


func cerrar():
	visible = false
	abierto = false
	
func abrir():
	visible = true
	abierto = true
	
