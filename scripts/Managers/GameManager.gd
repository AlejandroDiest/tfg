extends Node

# --- VARIABLES ORIGINALES ---
# Ajusta la ruta si es necesario, pero mantenemos la lógica
var inventario_recurso: Inv = preload("res://scenes/UI/Inventario/Inventario.tres") 
var menu_pausa = preload("res://scenes/UI/Menus/MenuPausa.tscn")
var dialogo_activo = false
var puerta_destino: String = ""
var inventario_abierto = false
var herrero_hablado: bool = false
var datos_jugador: Dictionary = {
	"oro": 0,
	"vida_maxima": 3,
	"vida_actual": 3,
	"dano": 0,
	"equipamiento": {},
	"volumen_musica": 1.0, 
	"volumen_sfx": 1.0
}

enum EstadoPueblo { 
	INICIO,          
	MISION_ACTIVA,    
	HERRERIA_FIXED,
	NOCHE
}
enum EstadoVendedor { 
	DESCONOCIDO,   
	MISION_ITEM,   
	CASA_REPARADA,
	TIENDA_ABIERTA  
}
enum EstadoCementerio {
	ZOMBIE,  
	VERJA,  
	ABIERTO  
}
var estado_pueblo = EstadoPueblo.INICIO
var estado_cementerio = EstadoCementerio.ZOMBIE
var es_de_noche: bool = false
signal cambio_horario(es_noche)

func alternar_dia_noche():
	es_de_noche = !es_de_noche 
	print("Cambiando hora. ¿Es noche?: ", es_de_noche)
	emit_signal("cambio_horario", es_de_noche)
	
	

var estado_actual_vendedor = EstadoVendedor.DESCONOCIDO

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pausar_juego()

func pausar_juego():
	if inventario_abierto:
		return
	var menu_instance = menu_pausa.instantiate()
	get_tree().root.add_child(menu_instance)
	get_tree().paused = true

func recibir_daño(): 
	datos_jugador.vida_actual -= 1
	if datos_jugador.vida_actual < 0: datos_jugador.vida_actual = 0
	print("Vida: ", datos_jugador.vida_actual)

func curar_personaje():
	datos_jugador.vida_actual = datos_jugador.vida_maxima

func respawnear():
	datos_jugador.vida_actual = datos_jugador.vida_maxima

func add_oro():
	datos_jugador.oro += 1
	print("Oro actual: ", datos_jugador.oro)

func aumentar_vida_maxima():
	datos_jugador.vida_maxima += 1
	datos_jugador.vida_actual = datos_jugador.vida_maxima
