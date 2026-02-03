extends Area2D

var item_data: InvItem = null 

func _ready():
	if item_data != null:
	
		$Sprite2D.texture = item_data.texturaItem
	else:
		print("¡Cuidado! Se ha creado un drop sin datos.")

func _on_body_entered(body):
	if body.name == "Personaje": 
		body.recolectar(item_data)
		queue_free()
