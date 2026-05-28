extends Panel

signal clic_derecho(indice)

@onready var item_sprite: TextureRect = $CenterContainer/Panel/item
@onready var label: Label = $CenterContainer/Panel/Label

func update(slot: InvSlot):
	if slot == null or slot.item == null:
		item_sprite.visible = false
		label.visible = false
	else:
		item_sprite.visible = true
		item_sprite.texture = slot.item.texturaItem 
		label.visible = true
		label.text = str(slot.cantItem)
		tooltip_text = slot.item.nombreItem + "\n" + slot.item.descripcion
		
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		clic_derecho.emit(get_index())
