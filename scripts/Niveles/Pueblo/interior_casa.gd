extends Node2D

@onready var filtro_noche: CanvasModulate = get_node_or_null("Noche")

@onready var jugador = get_node_or_null("Personaje") 

func _ready():
	actualizar_ambiente(GameManager.es_de_noche)
	
	if not GameManager.is_connected("cambio_horario", actualizar_ambiente):
		GameManager.connect("cambio_horario", actualizar_ambiente)
		
	# 3. --- MANTENEMOS EL SISTEMA DE PUERTAS INTACTO ---
	if SceneManager.get("destino_spawn_point") != null and SceneManager.destino_spawn_point != "":
		var marker = get_node_or_null(SceneManager.destino_spawn_point)
		if marker and jugador:
			jugador.global_position = marker.global_position
		SceneManager.destino_spawn_point = ""

func actualizar_ambiente(es_noche: bool):
	
	if filtro_noche:
		filtro_noche.visible = es_noche
	
