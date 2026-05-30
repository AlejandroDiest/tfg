extends CharacterBody2D

@onready var capa_dialogo = $CapaDialogo
@onready var retrato = $CapaDialogo/RetratoAnimado
@onready var label = $CapaDialogo/CajaTextoDialogo/Texto

var catalogo_herrero = [
	preload("res://scenes/Items/Equipo/ArmaduraCuero.tres"),
	preload("res://scenes/Items/Equipo/ArmaduraMalla.tres"),
	preload("res://scenes/Items/Equipo/ArmaduraHierro.tres"),	
	
	preload("res://scenes/Items/Equipo/EspadaOro.tres"),
	preload("res://scenes/Items/Equipo/EspadaAmatista.tres"),
	
	preload("res://scenes/Items/Equipo/AnilloRubi.tres"),
	preload("res://scenes/Items/Equipo/AnilloAmatista.tres")
	
]

var dialogos = [
	"¡Un placer conocerte, forastero! El vendedor me ha contado lo que hiciste en el cementerio.",
	"He vuelto a encender la vieja forja. Si me traes oro y materiales de esas bestias, te prepararé equipo en condiciones."
]

var jugador_cerca = false
var indice_frase = 0
var en_conversacion = false

func _ready():
	if capa_dialogo:
		capa_dialogo.visible = false

func _input(event):
	if event.is_action_pressed("interactuar"):
		if GameManager.inventario_abierto:
			return 
			
		if en_conversacion:
			avanzar_dialogo()
		elif jugador_cerca:
			iniciar_dialogo()

func iniciar_dialogo():
	if GameManager.herrero_hablado:
		abrir_menu_forja()
		return
		
	en_conversacion = true
	GameManager.dialogo_activo = true 
	indice_frase = 0
	capa_dialogo.visible = true
	retrato.play("default")
	mostrar_frase_actual()

func mostrar_frase_actual():
	label.text = dialogos[indice_frase]

func avanzar_dialogo():
	indice_frase += 1
	if indice_frase < dialogos.size():
		mostrar_frase_actual()
	else:
		finalizar_dialogo()

func finalizar_dialogo():
	en_conversacion = false
	capa_dialogo.visible = false
	retrato.stop()
	GameManager.dialogo_activo = false 
	
	GameManager.herrero_hablado = true 
	
	abrir_menu_forja()

func abrir_menu_forja():
	var interfaz_herrero = get_tree().get_first_node_in_group("HerreroGlobal")
	if interfaz_herrero:
		interfaz_herrero.abrir(catalogo_herrero)
	else:
		print("ERROR: No se encontró HerreroUI. ¿Está en la escena principal con el grupo 'HerreroGlobal'?")

func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("player"): 
		jugador_cerca = true
		
func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("player"): 
		jugador_cerca = false
