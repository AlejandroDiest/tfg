extends CanvasLayer

@onready var grid_comprar = $Panel/TabContainer/Comprar/MarginContainer/ScrollContainer/GridContainer
@onready var label_oro = $Panel/LabelOro
@onready var tab_container = $Panel/TabContainer

@onready var grid_vender = $Panel/TabContainer/Vender/MarginContainer/ScrollContainer/GridVender


@onready var popup_venta = $Panel/PopupVenta
@onready var label_nombre_popup = $Panel/PopupVenta/LabelNombre
@onready var slider_venta = $Panel/PopupVenta/HSlider
@onready var label_info_popup = $Panel/PopupVenta/LabelInfo
@onready var btn_confirmar_venta = $Panel/PopupVenta/BtnConfirmar
@onready var btn_cancelar_venta = $Panel/PopupVenta/BtnCancelar

var inventario_npc: Array = [] 
var item_seleccionado_para_venta = null
var slot_seleccionado_para_venta = null

func _ready():
	visible = false
	
	btn_cancelar_venta.pressed.connect(ocultar_popup)
	btn_confirmar_venta.pressed.connect(ejecutar_venta_slider)
	slider_venta.value_changed.connect(_on_slider_cambiado)
	
	popup_venta.visible = false

func abrir(items_a_la_venta: Array):
	inventario_npc = items_a_la_venta
	tab_container.current_tab = 0 
	ocultar_popup() 
	actualizar_ui()
	visible = true
	GameManager.inventario_abierto = true 
	
	var interfaz_inv = get_tree().get_first_node_in_group("InterfazInventario")
	if interfaz_inv:
		interfaz_inv.alternar_modo_tienda(true)

func cerrar():
	visible = false
	GameManager.inventario_abierto = false
	ocultar_popup()
	
	var interfaz_inv = get_tree().get_first_node_in_group("InterfazInventario")
	if interfaz_inv:
		interfaz_inv.alternar_modo_tienda(false)
		interfaz_inv.cerrar()

func actualizar_ui():
	label_oro.text = "Tu Oro: " + str(GameManager.datos_jugador.oro)
	
	for hijo in grid_comprar.get_children():
		hijo.queue_free()
	for item in inventario_npc:
		crear_boton_compra(item)
		
	for hijo in grid_vender.get_children():
		hijo.queue_free()
	preparar_lista_venta()

func crear_boton_compra(item):
	var btn = Button.new()
	btn.text = item.nombreItem + " (" + str(item.precio_compra) + "G)" 
	btn.icon = item.texturaItem
	btn.custom_minimum_size = Vector2(0, 50)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	if GameManager.datos_jugador.oro < item.precio_compra:
		btn.disabled = true
		
	btn.pressed.connect(func(): ejecutar_compra(item))
	grid_comprar.add_child(btn)

func ejecutar_compra(item_comprado):
	if GameManager.datos_jugador.oro >= item_comprado.precio_compra:
		var item_anadido = false
		
		for slot in GameManager.inventario_recurso.inventario:
			if slot.item != null and slot.item.nombreItem == item_comprado.nombreItem:
				slot.cantItem += 1
				item_anadido = true
				break
				
		if not item_anadido:
			for slot in GameManager.inventario_recurso.inventario:
				if slot.item == null:
					slot.item = item_comprado
					slot.cantItem = 1
					item_anadido = true
					break
					
		if item_anadido:
			GameManager.datos_jugador.oro -= item_comprado.precio_compra
			GameManager.inventario_recurso.update_ui.emit()
			actualizar_ui() 
		else:
			print("Inventario lleno")

func preparar_lista_venta():
	for slot in GameManager.inventario_recurso.inventario:
		if slot.item != null and slot.item.nombreItem != "BrazoZombie" and slot.item.precio_venta > 0:
			crear_boton_venta(slot)

func crear_boton_venta(slot_datos):
	var btn = Button.new()
	var item = slot_datos.item
	var precio_unidad = item.precio_venta
	
	btn.text = str(precio_unidad) + " de oro" + " (x" + str(slot_datos.cantItem) + ")"
	btn.icon = item.texturaItem
	btn.custom_minimum_size = Vector2(0, 50)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	btn.pressed.connect(func(): mostrar_popup_venta(slot_datos, precio_unidad))
	grid_vender.add_child(btn)

func mostrar_popup_venta(slot_datos, precio_unidad):
	item_seleccionado_para_venta = slot_datos.item
	slot_seleccionado_para_venta = slot_datos
	
	label_nombre_popup.text = "Vendiendo: 
		" + item_seleccionado_para_venta.nombreItem
	
	slider_venta.min_value = 1
	slider_venta.max_value = slot_datos.cantItem
	slider_venta.step = 1
	slider_venta.value = 1 
	
	_on_slider_cambiado(1.0)
	popup_venta.visible = true

func ocultar_popup():
	popup_venta.visible = false
	item_seleccionado_para_venta = null
	slot_seleccionado_para_venta = null

func _on_slider_cambiado(valor):
	var cantidad = int(valor)
	var precio_unidad = item_seleccionado_para_venta.precio_venta
	var oro_total = cantidad * precio_unidad
	label_info_popup.text = "Cantidad: " + str(cantidad) + "  
	Total: +" + str(oro_total) + "G"

func ejecutar_venta_slider():
	if slot_seleccionado_para_venta == null: return
	
	var cantidad_a_vender = int(slider_venta.value)
	var precio_unidad = item_seleccionado_para_venta.precio_venta
	var oro_ganado = cantidad_a_vender * precio_unidad
	
	GameManager.datos_jugador.oro += oro_ganado
	slot_seleccionado_para_venta.cantItem -= cantidad_a_vender
	
	if slot_seleccionado_para_venta.cantItem <= 0:
		slot_seleccionado_para_venta.item = null
		slot_seleccionado_para_venta.cantItem = 0
		
	GameManager.inventario_recurso.update_ui.emit()
	ocultar_popup()
	actualizar_ui()
