extends CanvasLayer

var abierto = false

# --- RECURSOS ---
@onready var inv: Inv = preload("res://scenes/UI/Inventario/Inventario.tres")

# --- REFERENCIAS A LOS PANELES ---
@onready var panel_inventario = $Inventario
@onready var panel_equipamiento = $Equipamiento
@onready var label_vida = $Equipamiento/Estadisticas/Vida/LabelVida
@onready var label_dano = $Equipamiento/Estadisticas/Dano/LabelDano

@onready var slots: Array = $Inventario/GridContainer.get_children()
# NUEVO: Cogemos todos los huecos de la izquierda
@onready var slots_equipo: Array = $Equipamiento/SlotsEquipamiento.get_children()

func _ready():
	inv.update_ui.connect(update_slots)
	update_slots()
	cerrar()
	
	# NUEVO: Conectar las señales de los clics a este script
	for i in range(slots.size()):
		if not slots[i].clic_derecho.is_connected(_on_slot_inventario_clic):
			slots[i].clic_derecho.connect(_on_slot_inventario_clic)
			
	for hueco in slots_equipo:
		if not hueco.clic_derecho_equipo.is_connected(_on_slot_equipo_clic):
			hueco.clic_derecho_equipo.connect(_on_slot_equipo_clic)
	
func update_slots():
	for i in range(min(inv.inventario.size(), slots.size())):
		slots[i].update(inv.inventario[i])
		
func _process(_delta):
	if Input.is_action_just_pressed("I"):
		if abierto:
			cerrar()
		else:
			abrir()

func actualizar_textos_estadisticas():
	label_vida.text = str(int(GameManager.datos_jugador.vida_maxima))
	label_dano.text = str(int(GameManager.datos_jugador.dano))
	
func cerrar():
	visible = false 
	abierto = false
	GameManager.inventario_abierto = false
	
func abrir():
	visible = true
	abierto = true
	GameManager.inventario_abierto = true
	actualizar_textos_estadisticas()


func _on_slot_inventario_clic(indice):
	var slot_datos = inv.inventario[indice]
	var item = slot_datos.item
	if item == null: return # Si hacemos clic en un hueco vacío, ignoramos
	
	# Buscamos en qué hueco de la izquierda encaja este objeto
	for hueco in slots_equipo:
		if hueco.tipo_permitido == item.tipo_item:
			var item_viejo = hueco.item_equipado
			
			# 1. Quitamos los stats del objeto viejo (si había)
			if item_viejo != null:
				GameManager.datos_jugador.dano -= item_viejo.bono_dano
				GameManager.datos_jugador.vida_maxima -= item_viejo.bono_vida
			
			# 2. Sumamos los stats del objeto nuevo
			GameManager.datos_jugador.dano += item.bono_dano
			GameManager.datos_jugador.vida_maxima += item.bono_vida
			
			# 3. Hacemos el intercambio físico
			hueco.equipar_item(item)
			slot_datos.item = item_viejo
			
			if item_viejo == null:
				slot_datos.cantItem = 0
			else:
				slot_datos.cantItem = 1 
				
			# 4. Refrescamos la pantalla
			inv.update_ui.emit()
			actualizar_textos_estadisticas()
			return

func _on_slot_equipo_clic(hueco):
	if hueco.item_equipado == null: return 
	
	var indice_vacio = -1
	for i in range(inv.inventario.size()):
		if inv.inventario[i].item == null:
			indice_vacio = i
			break
			
	if indice_vacio != -1: 
		var item_a_quitar = hueco.item_equipado
		
		# 1. Restamos sus stats
		GameManager.datos_jugador.dano -= item_a_quitar.bono_dano
		GameManager.datos_jugador.vida_maxima -= item_a_quitar.bono_vida
		
		# 2. Lo desequipamos y lo mandamos a la mochila
		hueco.desequipar_item()
		inv.inventario[indice_vacio].item = item_a_quitar
		inv.inventario[indice_vacio].cantItem = 1
		
		# 3. Refrescamos la pantalla
		inv.update_ui.emit()
		actualizar_textos_estadisticas()
