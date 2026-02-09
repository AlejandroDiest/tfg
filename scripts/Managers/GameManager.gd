extends Node

# --- VARIABLES ORIGINALES ---
# Ajusta la ruta si es necesario, pero mantenemos la lógica
var inventario_recurso: Inv = preload("res://scenes/UI/Inventario/Inventario.tres") 
var menu_pausa = preload("res://scenes/UI/Menus/MenuPausa.tscn")

var datos_jugador: Dictionary = {
	"oro": 0,
	"vida_maxima": 3,
	"vida_actual": 3, 
}

# --- ESTADOS DE MISIONES --
enum EstadoPueblo { 
	INICIO,          
	MISION_ACTIVA,    
	HERRERIA_FIXED,
	NOCHE
}

var estado_pueblo = EstadoPueblo.INICIO

var es_de_noche: bool = false
signal cambio_horario(es_noche)

func alternar_dia_noche():
	es_de_noche = !es_de_noche 
	print("Cambiando hora. ¿Es noche?: ", es_de_noche)
	emit_signal("cambio_horario", es_de_noche)
	
	
enum EstadoVendedor { 
	DESCONOCIDO,   
	MISION_MADERA,   
	CASA_REPARADA,    
	TIENDA_ABIERTA  
}
var estado_actual_vendedor = EstadoVendedor.DESCONOCIDO

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- INPUT (ESTO FALTABA: Para pausar con Escape) ---
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pausar_juego()

# --- LÓGICA DE GAMEPLAY ORIGINAL ---
func pausar_juego():
	var menu_instance = menu_pausa.instantiate()
	get_tree().root.add_child(menu_instance)
	get_tree().paused = true

func recibir_daño(): # Faltaba el argumento vacío por defecto o sin argumento como en tu original
	datos_jugador.vida_actual -= 1
	if datos_jugador.vida_actual < 0: datos_jugador.vida_actual = 0
	print("Vida: ", datos_jugador.vida_actual)

func curar_personaje():
	datos_jugador.vida_actual = datos_jugador.vida_maxima

# ESTA FALTABA EN LA VERSIÓN ANTERIOR
func respawnear():
	datos_jugador.vida_actual = datos_jugador.vida_maxima

func add_oro():
	datos_jugador.oro += 1
	print("Oro actual: ", datos_jugador.oro)

func aumentar_vida_maxima():
	datos_jugador.vida_maxima += 1
	datos_jugador.vida_actual = datos_jugador.vida_maxima
