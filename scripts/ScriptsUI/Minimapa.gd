extends SubViewportContainer

@onready var camara_mapa = $SubViewport/Camera2D
@onready var sub_viewport = $SubViewport
var jugador: Node2D = null

func _ready():
	
	sub_viewport.world_2d = get_viewport().world_2d
	
func _process(_delta):
	if not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("Jugador")
		return
	camara_mapa.global_position = jugador.global_position
