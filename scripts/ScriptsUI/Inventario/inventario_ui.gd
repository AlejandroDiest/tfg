extends NinePatchRect

var abierto = false

@onready var inv: Inv = preload("res://scenes/UI/Inventario/Inventario.tres")
@onready var slots: Array = $GridContainer.get_children()


func _ready():
	inv.update_ui.connect(update_slots)
	update_slots()
	cerrar()
	
func update_slots():
	for i in range(min(inv.inventario.size(), slots.size())):
		slots[i].update(inv.inventario[i])
		
func _process(_delta):
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
	
