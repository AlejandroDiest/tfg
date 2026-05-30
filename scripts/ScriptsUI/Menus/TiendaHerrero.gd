extends CanvasLayer

@onready var grid_forjar = $Panel/Comprar/MarginContainer/ScrollContainer/GridContainer


var inventario_herrero: Array = []

func _ready():
	visible = false
	
func abrir(items_para_forjar: Array):
	inventario_herrero = items_para_forjar
	actualizar_ui()
	visible = true
	GameManager.inventario_abierto = true 
	
	var interfaz_inv = get_tree().get_first_node_in_group("InterfazInventario")
	if interfaz_inv:
		interfaz_inv.alternar_modo_tienda(true)

func cerrar():
	visible = false
	GameManager.inventario_abierto = false
	
	var interfaz_inv = get_tree().get_first_node_in_group("InterfazInventario")
	if interfaz_inv:
		interfaz_inv.alternar_modo_tienda(false)
		interfaz_inv.cerrar()

func _process(_delta):
	if visible:
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("I"):
			cerrar()
			
func actualizar_ui():
	
	for hijo in grid_forjar.get_children():
		hijo.queue_free()
		
	for item in inventario_herrero:
		crear_boton_forja(item)
func crear_boton_forja(item):
	var lineas_de_texto = 1 
	if item.get("receta"):
		lineas_de_texto += item.receta.size() 
		
	var altura_dinamica = 85 + (lineas_de_texto * 18) 
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, altura_dinamica) 
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) 
	hbox.add_theme_constant_override("separation", 15) 
	hbox.set_begin(Vector2(10, 5)) 
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	btn.add_child(hbox)
	
	var icono = TextureRect.new()
	icono.texture = item.texturaItem
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.custom_minimum_size = Vector2(40, 40)
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icono)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(vbox)
	
	var label_nombre = Label.new()
	label_nombre.text = item.nombreItem
	
	if item.nombreItem.length() > 14:
		label_nombre.add_theme_font_size_override("font_size", 13) 
	else:
		label_nombre.add_theme_font_size_override("font_size", 16)
		
	label_nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	label_nombre.custom_minimum_size = Vector2(10, 0) 
	label_nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	vbox.add_child(label_nombre)
	
	var texto_coste = str(item.precio_compra) + " Oro"
	if item.get("receta"):
		for nombre_mat in item.receta:
			var cantidad = item.receta[nombre_mat]
			texto_coste += "\n" + str(cantidad) + "x " + nombre_mat
			
	var label_coste = Label.new()
	label_coste.text = texto_coste
	label_coste.add_theme_font_size_override("font_size", 12) 
	label_coste.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7)) 
	label_coste.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_coste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	label_coste.custom_minimum_size = Vector2(10, 0)
	label_coste.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	vbox.add_child(label_coste)
	
	var margen_abajo = Control.new()
	margen_abajo.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(margen_abajo)
	
	if GameManager.datos_jugador.oro < item.precio_compra or not tiene_materiales_receta(item):
		btn.disabled = true
		
	btn.pressed.connect(func(): ejecutar_forja(item))
	grid_forjar.add_child(btn)
	
func ejecutar_forja(item_comprado):
	if GameManager.datos_jugador.oro >= item_comprado.precio_compra and tiene_materiales_receta(item_comprado):
		
		var indice_vacio = -1
		for i in range(GameManager.inventario_recurso.inventario.size()):
			if GameManager.inventario_recurso.inventario[i].item == null:
				indice_vacio = i
				break
				
		if indice_vacio != -1:
			GameManager.datos_jugador.oro -= item_comprado.precio_compra
			
			if item_comprado.get("receta"):
				for nombre_mat in item_comprado.receta:
					var cantidad = item_comprado.receta[nombre_mat]
					quitar_material_del_inventario(nombre_mat, cantidad)
			
			GameManager.inventario_recurso.inventario[indice_vacio].item = item_comprado
			GameManager.inventario_recurso.inventario[indice_vacio].cantItem = 1
			
			GameManager.inventario_recurso.update_ui.emit()
			actualizar_ui() 
		else:
			print("¡Inventario lleno! No puedes forjar esto.")
			
func tiene_materiales_receta(item) -> bool:
	if not item.get("receta"): return true
	
	for nombre_mat in item.receta:
		var cantidad_pedida = item.receta[nombre_mat]
		if not tiene_suficiente_material(nombre_mat, cantidad_pedida):
			return false 
	return true

func tiene_suficiente_material(nombre_mat: String, cantidad_necesaria: int) -> bool:
	if cantidad_necesaria <= 0: return true 
	
	var cantidad_total = 0
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null and slot.item.nombreItem == nombre_mat:
			cantidad_total += slot.cantItem
	return cantidad_total >= cantidad_necesaria

func quitar_material_del_inventario(nombre_mat: String, cantidad_a_quitar: int):
	var restante = cantidad_a_quitar
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null and slot.item.nombreItem == nombre_mat:
			if slot.cantItem >= restante:
				slot.cantItem -= restante
				restante = 0
				if slot.cantItem == 0: 
					slot.item = null
			else:
				restante -= slot.cantItem
				slot.cantItem = 0
				slot.item = null
				
			if restante <= 0: break
