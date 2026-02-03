extends NinePatchRect

var abierto = false

@onready var inv: Inv = preload("res://scenes/UI/Inventario/Inventario.tres")
@onready var slots: Array = $GridContainer.get_children()


func _ready():
	update_slots()
	cerrar()
	
func update_slots():
	for i in range(min(inv.items.size(),slots.size())): 
		slots[i].update(inv.items[i])
		
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
	
