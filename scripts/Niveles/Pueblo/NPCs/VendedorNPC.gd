extends CharacterBody2D

# --- REFERENCIAS A LA INTERFAZ ---
@onready var capa_dialogo = $CapaDialogo
@onready var retrato = $CapaDialogo/RetratoAnimado
@onready var label = $CapaDialogo/CajaTextoDialogo/Texto
@onready var pantalla_negra = $CapaDialogo/PantallaNegra

# --- CONFIGURACIÓN ---
const NOMBRE_ITEM_JEFE = "BrazoZombie" 

# --- NUEVO: EL CATÁLOGO DE LA TIENDA ---
var catalogo_vendedor = [
	preload("res://scenes/Items/PocionVida_1.tres"),
	preload("res://scenes/Items/PocionVida_2.tres")
]

var dialogos = {
	"intro_1_a": "Saludos, forastero. Llegas en un momento terrible.",
	"intro_1_b": "Las bestias del cementerio, al este del pueblo, arrasaron nuestras casas y devoraron a nuestra gente.",
	"intro_1_c": "Si logramos que el herrero regrese, quizá aún tengamos una oportunidad.",

	"intro_2_a": "Es un maestro forjando armas y armaduras. Necesitamos su ayuda.",
	"intro_2_b": "En mi última expedición conseguí sellar la cripta de la que surgían esas criaturas... pero una logró escapar.",
	"intro_2_c": "Necesito que entres al cementerio y acabes con ella. Tráeme una prueba y convenceré al herrero para que vuelva.",

	"intro_3_a": "Escucha bien: no entres en las criptas sin haber descansado.",
	"intro_3_b": "Al norte hay una vieja casa abandonada. Aún es segura. Allí podrás dormir.",

	"esperando_material_a": "¿Aún no lo has encontrado? Sigue buscando en el cementerio.",
	"esperando_material_b": "El brazo de un zombi debería bastar.",

	"entregar_material_a": "¡Lo has conseguido!",
	"entregar_material_b": "Con esto el herrero no podrá negarse.",

	"llegada_herrero": "Gracias a ti, el herrero ha regresado. Habla con él cuando puedas.",

	"tienda": "Echa un vistazo. También compraré lo que no necesites."
}

# --- VARIABLES DE CONTROL DEL DIÁLOGO ---
var jugador_cerca = false
var frases_actuales: Array = []
var indice_frase: int = 0
var en_conversacion: bool = false
var en_cinematica: bool = false 
var esperando_cierre_cinematica: bool = false 

func _ready():
	if GameManager.estado_actual_vendedor >= GameManager.EstadoVendedor.CASA_REPARADA:
		activar_casa_reparada()
		
	if capa_dialogo:
		capa_dialogo.visible = false

func _input(event):
	if event.is_action_pressed("interactuar"):
		if GameManager.inventario_abierto:
			return
		if en_cinematica:
			return 
			
		if en_conversacion:
			avanzar_dialogo()
		elif jugador_cerca:
			iniciar_dialogo()

func iniciar_dialogo():
	var estado = GameManager.estado_actual_vendedor
	frases_actuales.clear()
	indice_frase = 0
	
	match estado:
		GameManager.EstadoVendedor.DESCONOCIDO:
			frases_actuales = [
				dialogos["intro_1_a"], dialogos["intro_1_b"], dialogos["intro_1_c"], 
				dialogos["intro_2_a"], dialogos["intro_2_b"], dialogos["intro_2_c"],
				dialogos["intro_3_a"], dialogos["intro_3_b"]                         
			]
			
		GameManager.EstadoVendedor.MISION_ITEM:
			if tiene_suficiente_recurso(NOMBRE_ITEM_JEFE, 1):
				frases_actuales = [dialogos["entregar_material_a"], dialogos["entregar_material_b"]]
			else:
				frases_actuales = [dialogos["esperando_material_a"], dialogos["esperando_material_b"]]
				
		GameManager.EstadoVendedor.CASA_REPARADA, GameManager.EstadoVendedor.TIENDA_ABIERTA:
			# Ya no vendemos aquí directo, solo decimos la frase y luego se abre el menú
			frases_actuales = [dialogos["tienda"]]

	if frases_actuales.size() > 0:
		en_conversacion = true
		GameManager.dialogo_activo = true 
		capa_dialogo.visible = true
		retrato.play("default")
		mostrar_frase_actual()

func mostrar_frase_actual():
	label.text = frases_actuales[indice_frase]

func avanzar_dialogo():
	if esperando_cierre_cinematica:
		esperando_cierre_cinematica = false
		en_conversacion = false
		GameManager.dialogo_activo = false 
		capa_dialogo.visible = false
		retrato.stop()
		return

	var estado = GameManager.estado_actual_vendedor
	indice_frase += 1
	
	if estado == GameManager.EstadoVendedor.DESCONOCIDO:
		if indice_frase == 3: 
			await hacer_cinematica_vista("CasaHerrero")
		elif indice_frase == 6: 
			await hacer_cinematica_vista("SalidaCementerio")
		elif indice_frase == 8: 
			await hacer_cinematica_vista("CasaJugador")

	if indice_frase < frases_actuales.size():
		mostrar_frase_actual()
	else:
		finalizar_dialogo()

func hacer_cinematica_vista(grupo_destino: String):
	en_cinematica = true
	capa_dialogo.visible = false 
	retrato.stop()
	
	var camara = get_viewport().get_camera_2d()
	var destino = get_tree().get_first_node_in_group(grupo_destino)
	
	if camara and destino:
		var pos_orig = camara.global_position
		
		var tween_ida = create_tween()
		tween_ida.tween_property(camara, "global_position", destino.global_position, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_ida.finished
		
		await get_tree().create_timer(2.0).timeout
		
		var tween_vuelta = create_tween()
		tween_vuelta.tween_property(camara, "global_position", pos_orig, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_vuelta.finished
		
		camara.position = Vector2.ZERO 
		
	capa_dialogo.visible = true
	retrato.play("default")
	en_cinematica = false

func cinematica_reparar_casa():
	en_cinematica = true
	capa_dialogo.visible = false
	retrato.stop()
	
	var camara = get_viewport().get_camera_2d()
	var destino = get_tree().get_first_node_in_group("CasaHerrero")
	
	if camara and destino:
		var pos_orig = camara.global_position
		
		var tween_ida = create_tween()
		tween_ida.tween_property(camara, "global_position", destino.global_position, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_ida.finished
		
		await get_tree().create_timer(1.0).timeout
		
		pantalla_negra.modulate.a = 0.0 
		capa_dialogo.visible = true 
		pantalla_negra.visible = true
		
		var tween_fade_in = create_tween()
		tween_fade_in.tween_property(pantalla_negra, "modulate:a", 1.0, 1.5)
		await tween_fade_in.finished
		
		reparar_casa_visual()
		
		await get_tree().create_timer(0.5).timeout
		
		var tween_fade_out = create_tween()
		tween_fade_out.tween_property(pantalla_negra, "modulate:a", 0.0, 1.5)
		await tween_fade_out.finished
		
		pantalla_negra.visible = false
		capa_dialogo.visible = false
		
		await get_tree().create_timer(1.5).timeout
		
		var tween_vuelta = create_tween()
		tween_vuelta.tween_property(camara, "global_position", pos_orig, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_vuelta.finished
		
		camara.position = Vector2.ZERO
		
	frases_actuales = [dialogos["llegada_herrero"]]
	indice_frase = 0
	mostrar_frase_actual()
	
	capa_dialogo.visible = true
	retrato.play("default")
	
	esperando_cierre_cinematica = true 
	en_conversacion = true
	en_cinematica = false 

func finalizar_dialogo():
	en_conversacion = false
	capa_dialogo.visible = false
	retrato.stop()
	
	var estado = GameManager.estado_actual_vendedor
	var lanzar_cinematica = false
	
	match estado:
		GameManager.EstadoVendedor.DESCONOCIDO:
			GameManager.estado_actual_vendedor = GameManager.EstadoVendedor.MISION_ITEM
			
		GameManager.EstadoVendedor.MISION_ITEM:
			if tiene_suficiente_recurso(NOMBRE_ITEM_JEFE, 1):
				quitar_recurso_del_inventario(NOMBRE_ITEM_JEFE, 1)
				GameManager.estado_pueblo = GameManager.EstadoPueblo.HERRERIA_FIXED
				GameManager.estado_actual_vendedor = GameManager.EstadoVendedor.CASA_REPARADA
				GameManager.estado_cementerio = GameManager.EstadoCementerio.ABIERTO
				lanzar_cinematica = true
				cinematica_reparar_casa()
				
		GameManager.EstadoVendedor.CASA_REPARADA, GameManager.EstadoVendedor.TIENDA_ABIERTA:
			abrir_menu_tienda()

	if not lanzar_cinematica:
		GameManager.dialogo_activo = false

func tiene_suficiente_recurso(nombre_item: String, cantidad_necesaria: int) -> bool:
	var cantidad_total = 0
	for slot in GameManager.inventario_recurso.inventario: 
		if slot.item != null and slot.item.nombreItem == nombre_item:
			cantidad_total += slot.cantItem
	return cantidad_total >= cantidad_necesaria

func quitar_recurso_del_inventario(nombre_item: String, cantidad_a_quitar: int):
	var restante = cantidad_a_quitar
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null and slot.item.nombreItem == nombre_item:
			if slot.cantItem >= restante:
				slot.cantItem -= restante
				restante = 0
				if slot.cantItem == 0: slot.item = null
			else:
				restante -= slot.cantItem
				slot.cantItem = 0
				slot.item = null
			if restante <= 0: break
	GameManager.inventario_recurso.update_ui.emit() 

func reparar_casa_visual():
	var casa = get_tree().get_first_node_in_group("CasaHerrero")
	if casa:
		for hijo in casa.get_children():
			if hijo.name == "HornoAbandonado":
				hijo.visible = false
			else:
				hijo.visible = true
	else:
		print("ERROR: No se encuentra casaherrero")

func activar_casa_reparada():
	var casa = get_tree().get_first_node_in_group("CasaHerrero")
	if casa:
		for hijo in casa.get_children():
			if hijo.name == "HornoAbandonado":
				hijo.visible = false
			else:
				hijo.visible = true

func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("player"): 
		jugador_cerca = true
		
func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("player"): 
		jugador_cerca = false

func abrir_menu_tienda():
	var interfaz_tienda = get_tree().get_first_node_in_group("TiendaGlobal")
	if interfaz_tienda:
		interfaz_tienda.abrir(catalogo_vendedor)
	else:
		print("ERROR: No se encontró la TiendaUI. ¿La añadiste a la escena y le pusiste el grupo 'TiendaGlobal'?")
