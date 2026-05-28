extends CharacterBody2D

# --- REFERENCIAS A LA INTERFAZ ---
@onready var capa_dialogo = $CapaDialogo
@onready var retrato = $CapaDialogo/RetratoAnimado
@onready var label = $CapaDialogo/CajaTextoDialogo/Texto
@onready var pantalla_negra = $CapaDialogo/PantallaNegra

# --- CONFIGURACIÓN ---
const NOMBRE_ITEM_JEFE = "NucleoBoss"

var dialogos = {
	"intro_1_a": "Saludos, forastero. Llegas a un lugar marchito.",
	"intro_1_b": "Las bestias del cementerio del este devoraron nuestro hogar y a nuestra gente.",
	"intro_2_a": "Pero aún hay esperanza. Si te adentras en sus dominios y recuperas materiales de valor...",
	"intro_2_b": "...podré financiar el regreso del Herrero. Con su ayuda, este pueblo podría llegar a renacer.",
	"intro_3_a": "Un consejo: no te enfrentes a las criptas sin haber descansado.",
	"intro_3_b": "Al norte encontrarás una vieja casa segura. Refúgiate allí antes de partir.",
	
	"esperando_material_a": "¿Aún no tienes los materiales? Busca en el cementerio.",
	"esperando_material_b": "Creo que el nucleo de un gran monstruo podria servir.",
	"entregar_material_a": "¡Increíble!",
	"entregar_material_b": "Con esto seguro que consigo que el Herrero vuelva.",
	"llegada_herrero": "Gracias a ti he conseguido convencer al Herrero, ¡Prueba a hablar con el, seguro que te ayuda!",
	"tienda": "Echa un vistazo a mis mercancías. Te compro lo que te sobre."
}

# --- VARIABLES DE CONTROL DEL DIÁLOGO ---
var jugador_cerca = false
var frases_actuales: Array = []
var indice_frase: int = 0
var en_conversacion: bool = false
var en_cinematica: bool = false 
var esperando_cierre_cinematica: bool = false # Seguro para el texto final

func _ready():
	if GameManager.estado_actual_vendedor >= GameManager.EstadoVendedor.CASA_REPARADA:
		activar_casa_reparada()
		
	if capa_dialogo:
		capa_dialogo.visible = false

func _input(event):
	
	if event.is_action_pressed("interactuar"):
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
				dialogos["intro_1_a"], dialogos["intro_1_b"],
				dialogos["intro_2_a"], dialogos["intro_2_b"],
				dialogos["intro_3_a"], dialogos["intro_3_b"]
			]
			
		GameManager.EstadoVendedor.MISION_ITEM:
			if tiene_suficiente_recurso(NOMBRE_ITEM_JEFE, 1):
				frases_actuales = [dialogos["entregar_material_a"], dialogos["entregar_material_b"]]
			else:
				frases_actuales = [dialogos["esperando_material_a"], dialogos["esperando_material_b"]]
				
		GameManager.EstadoVendedor.CASA_REPARADA, GameManager.EstadoVendedor.TIENDA_ABIERTA:
			var oro_ganado = calcular_oro_tienda()
			if oro_ganado > 0:
				frases_actuales = ["¡Hola de nuevo!", "He comprado tus materiales por " + str(oro_ganado) + " monedas de oro."]
			else:
				frases_actuales = [dialogos["tienda"], "No tienes materiales para vender ahora mismo."]

	if frases_actuales.size() > 0:
		en_conversacion = true
		GameManager.dialogo_activo = true 
		capa_dialogo.visible = true
		retrato.play("default")
		mostrar_frase_actual()

func mostrar_frase_actual():
	label.text = frases_actuales[indice_frase]

func avanzar_dialogo():
	# --- INTERCEPTOR: Cierra el diálogo después de la cinemática ---
	if esperando_cierre_cinematica:
		esperando_cierre_cinematica = false
		en_conversacion = false
		GameManager.dialogo_activo = false # Liberamos al jugador
		capa_dialogo.visible = false
		retrato.stop()
		return

	var estado = GameManager.estado_actual_vendedor
	indice_frase += 1
	
	if estado == GameManager.EstadoVendedor.DESCONOCIDO:
		if indice_frase == 2: 
			await hacer_cinematica_vista("SalidaCementerio")
		elif indice_frase == 4: 
			await hacer_cinematica_vista("CasaHerrero")
		elif indice_frase == 6: 
			await hacer_cinematica_vista("CasaJugador")

	if indice_frase < frases_actuales.size():
		mostrar_frase_actual()
	else:
		finalizar_dialogo()

# --- VIAJE DE CÁMARA INICIAL ---
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

# --- CINEMÁTICA CON FUNDIDO A NEGRO Y TEXTO FINAL ---
func cinematica_reparar_casa():
	en_cinematica = true
	capa_dialogo.visible = false
	retrato.stop()
	
	var camara = get_viewport().get_camera_2d()
	var destino = get_tree().get_first_node_in_group("CasaHerrero")
	
	if camara and destino:
		var pos_orig = camara.global_position
		
		# 1. Desplazar cámara a la casa
		var tween_ida = create_tween()
		tween_ida.tween_property(camara, "global_position", destino.global_position, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_ida.finished
		
		# 2. Observar la casa destruida 1 segundo
		await get_tree().create_timer(1.0).timeout
		
		# 3. FUNDIDO A NEGRO SUAVE
		pantalla_negra.modulate.a = 0.0 
		capa_dialogo.visible = true 
		pantalla_negra.visible = true
		
		var tween_fade_in = create_tween()
		tween_fade_in.tween_property(pantalla_negra, "modulate:a", 1.0, 1.5)
		await tween_fade_in.finished
		
		# 4. Cambiamos la estructura de la casa
		reparar_casa_visual()
		
		await get_tree().create_timer(0.5).timeout
		
		# 5. FUNDIDO A TRANSPARENTE SUAVE
		var tween_fade_out = create_tween()
		tween_fade_out.tween_property(pantalla_negra, "modulate:a", 0.0, 1.5)
		await tween_fade_out.finished
		
		pantalla_negra.visible = false
		capa_dialogo.visible = false
		
		await get_tree().create_timer(1.5).timeout
		
		# 6. Volver la cámara al jugador
		var tween_vuelta = create_tween()
		tween_vuelta.tween_property(camara, "global_position", pos_orig, 2.5).set_trans(Tween.TRANS_SINE)
		await tween_vuelta.finished
		
		camara.position = Vector2.ZERO
		
	# --- CARGAR TEXTO DE DESPEDIDA ---
	frases_actuales = [dialogos["llegada_herrero"]]
	indice_frase = 0
	mostrar_frase_actual()
	
	capa_dialogo.visible = true
	retrato.play("default")
	
	esperando_cierre_cinematica = true # Activamos el seguro
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
				
				lanzar_cinematica = true
				cinematica_reparar_casa()
				
		GameManager.EstadoVendedor.CASA_REPARADA, GameManager.EstadoVendedor.TIENDA_ABIERTA:
			ejecutar_venta_recursos()

	if not lanzar_cinematica:
		GameManager.dialogo_activo = false

# --- LÓGICA DE INVENTARIO Y TIENDA ---
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

func calcular_oro_tienda() -> int:
	var oro = 0
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null and slot.item.nombreItem != NOMBRE_ITEM_JEFE:
			oro += slot.cantItem * 5
	return oro

func ejecutar_venta_recursos():
	var oro_ganado = calcular_oro_tienda()
	if oro_ganado > 0:
		for slot in GameManager.inventario_recurso.inventario:
			if slot.item != null and slot.item.nombreItem != NOMBRE_ITEM_JEFE:
				slot.item = null
				slot.cantItem = 0
		GameManager.datos_jugador.oro += oro_ganado
		GameManager.inventario_recurso.update_ui.emit()

# --- SISTEMA MEJORADO DE INTERRUPTORES ---
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

# --- DETECCIÓN ---
func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("player"): 
		jugador_cerca = true
func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("player"): jugador_cerca = false
