extends Resource

class_name Inv
signal update_ui

@export var items: Array[InvSlot]

func insertar(item: InvItem):
	for slot in items:
		if slot.item == null:
			slot.item = item
			update_ui.emit() 
			return 
			
	print("¡Inventario lleno! No cabe nada más.")
