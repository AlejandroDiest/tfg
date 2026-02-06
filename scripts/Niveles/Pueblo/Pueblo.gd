extends Node2D

@onready var jugador = $Personaje 

func _ready():
	
	#limites para la camara en el pueblo
	var camara = jugador.get_node("Camera2D")
	var HUD = jugador.get_node("HUD")
	var minimapa = HUD.get_node("MinimapaUI")
	var camara_minimapa = minimapa.get_node("SubViewportContainer/SubViewport/Camera2D")
	if camara:
		camara.limit_left = -850
		camara_minimapa.limit_left = -1000
		camara_minimapa.limit_top = -449
		camara.limit_top = -449
		camara_minimapa.limit_right = 1200
		camara.limit_right = 1054
		camara_minimapa.limit_bottom = 862
		camara.limit_bottom = 862
