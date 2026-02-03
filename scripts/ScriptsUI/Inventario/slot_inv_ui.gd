extends Panel

@onready var item_sprite: Sprite2D = $CenterContainer/Panel/item
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
		
