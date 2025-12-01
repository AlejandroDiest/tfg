extends Node;
@export_file("res://scenes/Pruebas.tscn") var escena_destino: String 
@export var marcador_destino: String = "SalidaCasa"
func _on_zona_interaccion_interactuado() -> void:
	GM.cambiar_y_posicionar(escena_destino, marcador_destino)
