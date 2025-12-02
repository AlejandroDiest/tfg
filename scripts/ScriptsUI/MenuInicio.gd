extends Control

# Referencias a los contenedores
@onready var menu_inicio = $MenuInicio
@onready var menu_slots = $MenuSlots

# Referencias a los botones de slots (para cambiarles el texto si quieres)
@onready var btn_slot_0 = $MenuSlots/VBoxContainer/BtnSlot0
@onready var btn_slot_1 = $MenuSlots/VBoxContainer/BtnSlot1
@onready var btn_slot_2 = $MenuSlots/VBoxContainer/BtnSlot2

func _ready():
	if get_tree().paused:
		get_tree().paused = false
	# Conectamos botones del Menú Principal
	$MenuInicio/VBoxContainer/BtnJugar.pressed.connect(_on_btn_jugar_pressed)
	$MenuInicio/VBoxContainer/BtnSalir.pressed.connect(_on_btn_salir_pressed)
	# (Aquí iría el de Opciones si lo tienes)

	# Conectamos botones de los Slots
	btn_slot_0.pressed.connect(func(): _cargar_slot(0))
	btn_slot_1.pressed.connect(func(): _cargar_slot(1))
	btn_slot_2.pressed.connect(func(): _cargar_slot(2))
	
	# Botón de volver
	$MenuSlots/VBoxContainer/BtnAtras.pressed.connect(_on_btn_atras_pressed)
	
	# Aseguramos el estado inicial
	menu_inicio.visible = true
	menu_slots.visible = false

# --- LÓGICA DE NAVEGACIÓN ---

func _on_btn_jugar_pressed():
	# 1. Ocultamos el menú principal
	menu_inicio.visible = false
	# 2. Mostramos el menú de slots
	menu_slots.visible = true
	
	# OPCIONAL: Actualizar texto de los botones según si hay partida
	actualizar_textos_slots()

func _on_btn_atras_pressed():
	# Hacemos lo contrario
	menu_slots.visible = false
	menu_inicio.visible = true

func _on_btn_salir_pressed():
	get_tree().quit()

# --- LÓGICA DE CARGA ---

func _cargar_slot(numero_slot: int):
	print("Cargando Slot ", numero_slot)
	
	# 1. Le decimos al GM qué slot usar
	GM.partida_actual = numero_slot
	
	# 2. Cargamos datos (o iniciamos de cero si no existen)
	GM.cargar_partida()
	
	# 3. Entramos al juego
	GM.cambiar_y_posicionar("res://scenes/EscenaPrincipal.tscn", "InicioJuego")

# --- EXTRA: Para que quede bonito ---
func actualizar_textos_slots():
	# Comprobamos cada slot usando la función del GM
	if GM.existe_partida_en_slot(0):
		btn_slot_0.text = "Partida 1 (Continuar)"
	else:
		btn_slot_0.text = "Partida 1 (Nueva)"
		
	if GM.existe_partida_en_slot(1):
		btn_slot_1.text = "Partida 2 (Continuar)"
	else:
		btn_slot_1.text = "Partida 2 (Nueva)"
		
	if GM.existe_partida_en_slot(2):
		btn_slot_2.text = "Partida 3 (Continuar)"
	else:
		btn_slot_2.text = "Partida 3 (Nueva)"
