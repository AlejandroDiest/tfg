extends CharacterBody2D

# Referencias a nodos hijos (asegúrate de tenerlos o quita estas líneas)
@onready var label = $LabelDialogo # Un Label encima de su cabeza
@onready var anim_player = $AnimationPlayer # Para animaciones si tienes

# Configuración
const MADERA_NECESARIA = 10
const NOMBRE_ITEM_MADERA = "Madera" # El nombre exacto que tenga tu item en el Resource

# Textos (Diccionario simple)
var dialogos = {
	"hola": "¡Hola viajero! Mi tienda fue destruida por los monstruos...",
	"pedir": "Si me traes 10 de madera, podré reconstruirla y venderte pociones.",
	"esperando": "¿Aún no tienes la madera? Busca en el bosque.",
	"gracias": "¡Increíble! ¡Has reparado mi tienda! Muchas gracias.",
	"tienda": "Echa un vistazo a mis mercancías."
}

var jugador_cerca = false

func _ready():
	# Si la casa ya estaba reparada de antes, asegúrate de que se vea reparada al iniciar
	if GameManager.estado_actual_vendedor >= GameManager.EstadoVendedor.CASA_REPARADA:
		activar_casa_reparada()

func _input(event):
	if event.is_action_pressed("interactuar") and jugador_cerca:
		gestionar_interaccion()

func gestionar_interaccion():
	var estado = GameManager.estado_actual_vendedor
	
	match estado:
		GameManager.EstadoVendedor.DESCONOCIDO:
			mostrar_texto(dialogos["hola"] + " " + dialogos["pedir"])
			GameManager.estado_actual_vendedor = GameManager.EstadoVendedor.MISION_MADERA
			
		GameManager.EstadoVendedor.MISION_MADERA:
			# AQUÍ COMPROBAMOS EL INVENTARIO
			if tiene_suficiente_madera():
				quitar_madera_del_inventario()
				mostrar_texto(dialogos["gracias"])
				
				# ¡Magia! Reparamos la casa y avanzamos la misión
				reparar_casa_visual()
				GameManager.estado_actual_vendedor = GameManager.EstadoVendedor.CASA_REPARADA
			else:
				mostrar_texto(dialogos["esperando"])
				
		GameManager.EstadoVendedor.CASA_REPARADA:
			mostrar_texto(dialogos["tienda"])
			GameManager.estado_actual_vendedor = GameManager.EstadoVendedor.TIENDA_ABIERTA
			abrir_tienda_ui()
			
		GameManager.EstadoVendedor.TIENDA_ABIERTA:
			abrir_tienda_ui()

# --- LÓGICA DE INVENTARIO (Usando tu GameManager) ---
func tiene_suficiente_madera() -> bool:
	# Recorremos los slots del inventario global
	var cantidad_total = 0
	for slot in GameManager.inventario_recurso.inventario: 
		if slot.item != null and slot.item.name == NOMBRE_ITEM_MADERA:
			cantidad_total += slot.cantItem
	
	return cantidad_total >= MADERA_NECESARIA

func quitar_madera_del_inventario():
	var madera_restante_a_quitar = MADERA_NECESARIA
	
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null and slot.item.name == NOMBRE_ITEM_MADERA:
			if slot.cantItem >= madera_restante_a_quitar:
				slot.cantItem -= madera_restante_a_quitar
				madera_restante_a_quitar = 0
				if slot.cantItem == 0: slot.item = null
			else:
				madera_restante_a_quitar -= slot.cantItem
				slot.cantItem = 0
				slot.item = null
			
			if madera_restante_a_quitar <= 0:
				break
	
	GameManager.inventario_recurso.update_ui.emit() 

# --- VISUALES ---
func reparar_casa_visual():
	var casa = get_tree().get_first_node_in_group("CasaVendedor")
	if casa:

		var anim = casa.get_node_or_null("AnimationPlayer")
		if anim: anim.play("Reparar")

func activar_casa_reparada():
	
	var casa = get_tree().get_first_node_in_group("CasaVendedor")
	if casa:
		var anim = casa.get_node_or_null("AnimationPlayer")
		if anim: anim.play("EstadoReparado") 

func mostrar_texto(texto):
	if label:
		label.text = texto
		label.visible = true
		await get_tree().create_timer(4.0).timeout
		label.visible = false
	print("Vendedor dice: ", texto)

func abrir_tienda_ui():
	print("Abriendo menú de tienda...")

func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("player"): jugador_cerca = true

func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("player"): jugador_cerca = false
