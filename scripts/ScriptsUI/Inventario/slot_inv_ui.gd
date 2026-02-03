extends Panel

@onready var item_sprite: Sprite2D = $CenterContainer/Panel/item

func update(item: InvItem):
	if item == null:
		item_sprite.visible = false
	else:
		item_sprite.visible = true
		item_sprite.texture = item.texturaItem
