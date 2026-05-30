extends Resource

class_name Inv
signal update_ui

@export var inventario: Array[InvSlot]

func insertar(item: InvItem):
	for slot in inventario:
		
		if slot.item == item:
			if slot.cantItem == 99:
				continue
			slot.cantItem += 1
			update_ui.emit()
			return
			
		if slot.item == null:
			slot.item = item
			slot.cantItem = 1
			update_ui.emit() 
			return 
	print("Inventario lleno.")

func reset():
	for slot in inventario: 
		slot.item = null
		slot.cantItem = 0
		
	update_ui.emit()
