extends Node2D
@onready var personaje: CharacterBody2D = $Node2D/Personaje
@onready var luces_noche = get_node_or_null("LucesNoche")
@onready var luces_dia = get_node_or_null("LucesDia")
@onready var jugador = $Node2D/Personaje
@onready var filtro_noche = $Noche 
func _ready():
	configurar_camaras()
	actualizar_ambiente(GameManager.es_de_noche)
	GameManager.connect("cambio_horario", actualizar_ambiente)
	if SceneManager.destino_spawn_point != "":
		var marker = get_node_or_null(SceneManager.destino_spawn_point)
		
		if marker and jugador:
		
			jugador.global_position = marker.global_position
			
		SceneManager.destino_spawn_point = ""
func actualizar_ambiente(es_noche: bool):
	
	if filtro_noche:
		filtro_noche.visible = es_noche
	
	var antorcha = jugador.get_node_or_null("AntorchaPueblo")
	if antorcha:
		antorcha.visible = es_noche 
	if !es_noche:
		personaje.modulate = Color(1, 1, 1)
		
	if luces_noche:
		luces_noche.visible = es_noche
	if luces_dia:
		luces_dia.visible = !es_noche
	gestionar_npcs(es_noche)
	
func gestionar_npcs(es_noche: bool):
	var npcs = get_tree().get_nodes_in_group("NPC")
	for npc in npcs:
		var debe_estar_activo = not es_noche
		if npc.name == "Herrero":
			if GameManager.estado_actual_vendedor < GameManager.EstadoVendedor.CASA_REPARADA:
				debe_estar_activo = false
		if debe_estar_activo:
			npc.visible = true
			npc.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			npc.visible = false
			npc.process_mode = Node.PROCESS_MODE_DISABLED
			
func configurar_camaras():
	if not jugador.has_node("Camera2D") or not jugador.has_node("HUD"):
		return
		
	var camara = jugador.get_node("Camera2D")
	var minimapa_cam = jugador.get_node("HUD/MinimapaUI/SubViewportContainer/SubViewport/Camera2D")
	
	camara.limit_left = -870
	camara.limit_right = 1272.0
	camara.limit_bottom = 862
	
	if minimapa_cam:
		minimapa_cam.limit_left = -1000
		minimapa_cam.limit_top = -1300
		minimapa_cam.limit_right = 1450
		minimapa_cam.limit_bottom = 862

func _input(event):
	if event.is_action_pressed("debug_noche"):
		GameManager.alternar_dia_noche()
