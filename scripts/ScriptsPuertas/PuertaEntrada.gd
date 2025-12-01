extends Node2D;
@export_file("res://scenes/InteriorCasa.tscn") var escena_destino: String 
@export var marcador_destino: String = "EntradaCasa"
func _on_zona_interaccion_interactuado() -> void:
	GM.cambiar_y_posicionar(escena_destino, marcador_destino)
