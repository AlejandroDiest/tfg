extends Node2D

@onready var personaje: CharacterBody2D = $Node2D/Personaje
@onready var jugador = $Node2D/Personaje
@onready var filtro_noche = $Noche 

@onready var verja = get_node_or_null("Condicionales/Berja")
@onready var zombie = get_node_or_null("Condicionales/EnemigoBase")

func _ready():
	configurar_camaras()
	
	GameManager.es_de_noche = true 
	filtro_noche.visible = true
	var antorcha = jugador.get_node_or_null("AntorchaPueblo")
	if antorcha:
		antorcha.visible = true
	
	personaje.modulate = Color(1, 1, 1)
	if zombie:
		# 1. Comprobamos si la misión ya está terminada
		var mision_completada = GameManager.estado_actual_vendedor >= GameManager.EstadoVendedor.CASA_REPARADA
		
		# 2. Comprobamos si el jugador lleva el brazo en la mochila
		var tiene_brazo = false
		if GameManager.inventario_recurso != null:
			for slot in GameManager.inventario_recurso.inventario:
				if slot.item != null and slot.item.nombreItem == "BrazoZombie":
					tiene_brazo = true
					break
		
		# 3. Si ya ha entregado el brazo, o si lo lleva encima, el zombie no reaparece.
		# Pero si NO lo tiene, ignoramos este if y el zombie se queda en el mapa.
		if mision_completada or tiene_brazo:
			zombie.queue_free()
	match GameManager.estado_cementerio:
		GameManager.EstadoCementerio.ZOMBIE:
			pass 
			
		GameManager.EstadoCementerio.VERJA:
			if zombie:
				zombie.queue_free()
				
		GameManager.EstadoCementerio.ABIERTO:
			if zombie:
				zombie.queue_free()
			if verja:
				verja.queue_free()

func configurar_camaras():
	if not jugador.has_node("Camera2D") or not jugador.has_node("HUD"):
		return
		
	var camara = jugador.get_node("Camera2D")
	var minimapa_cam = jugador.get_node("HUD/MinimapaUI/SubViewportContainer/SubViewport/Camera2D")
	
	camara.limit_left = 10
	camara.limit_right = 1428.0
	camara.limit_bottom = 855
	
	if minimapa_cam:
		minimapa_cam.limit_left = 10
		minimapa_cam.limit_top = -1300
		minimapa_cam.limit_right = 1428.0
		minimapa_cam.limit_bottom = 528.0
