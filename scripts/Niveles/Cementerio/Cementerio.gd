extends Node2D
@onready var personaje: CharacterBody2D = $Node2D/Personaje

@onready var jugador = $Node2D/Personaje
@onready var filtro_noche = $Noche 
func _ready():
	configurar_camaras()
	var antorcha = jugador.get_node_or_null("AntorchaPueblo")
	filtro_noche.visible=true
	if antorcha:
		antorcha.visible = true
		personaje.modulate = Color(1, 1, 1)



		

func configurar_camaras():
	if not jugador.has_node("Camera2D") or not jugador.has_node("HUD"):
		return
		
	var camara = jugador.get_node("Camera2D")
	var minimapa_cam = jugador.get_node("HUD/MinimapaUI/SubViewportContainer/SubViewport/Camera2D")
	
	camara.limit_left = 10
	camara.limit_right = 1272.0
	camara.limit_bottom = 862
	
	if minimapa_cam:
		minimapa_cam.limit_left = 10
		minimapa_cam.limit_top = -1300
		minimapa_cam.limit_right = 1450
		minimapa_cam.limit_bottom = 862
