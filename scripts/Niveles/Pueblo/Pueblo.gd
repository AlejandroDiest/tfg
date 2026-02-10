extends Node2D
@onready var personaje: CharacterBody2D = $Personaje

@onready var jugador = $Personaje 
@onready var filtro_noche = $Noche 
func _ready():
	configurar_camaras()
	actualizar_ambiente(GameManager.es_de_noche)
	GameManager.connect("cambio_horario", actualizar_ambiente)

func actualizar_ambiente(es_noche: bool):
	
	if filtro_noche:
		filtro_noche.visible = es_noche
	
	var antorcha = jugador.get_node_or_null("AntorchaPueblo")
	if antorcha:
		antorcha.visible = es_noche 
	if !es_noche:
		personaje.modulate = Color(1, 1, 1)

func configurar_camaras():
	if not jugador.has_node("Camera2D") or not jugador.has_node("HUD"):
		return
		
	var camara = jugador.get_node("Camera2D")
	var minimapa_cam = jugador.get_node("HUD/MinimapaUI/SubViewportContainer/SubViewport/Camera2D")
	
	camara.limit_left = -870
	camara.limit_right = 1054
	camara.limit_bottom = 862
	
	if minimapa_cam:
		minimapa_cam.limit_left = -1000
		minimapa_cam.limit_top = -1300
		minimapa_cam.limit_right = 1200
		minimapa_cam.limit_bottom = 862

func _input(event):
	if event.is_action_pressed("debug_noche"):
		GameManager.alternar_dia_noche()
