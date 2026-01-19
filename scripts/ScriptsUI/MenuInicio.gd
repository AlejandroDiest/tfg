extends Control

@onready var menu_inicio = $MenuInicio
@onready var menu_slots = $MenuSlots

@onready var btn_slot_0 = $MenuSlots/VBoxContainer/BtnSlot0
@onready var btn_slot_1 = $MenuSlots/VBoxContainer/BtnSlot1
@onready var btn_slot_2 = $MenuSlots/VBoxContainer/BtnSlot2

func _ready():
	if get_tree().paused:
		get_tree().paused = false
	$MenuInicio/VBoxContainer/BtnJugar.pressed.connect(_on_btn_jugar_pressed)
	$MenuInicio/VBoxContainer/BtnSalir.pressed.connect(_on_btn_salir_pressed)

	btn_slot_0.pressed.connect(func(): _cargar_slot(0))
	btn_slot_1.pressed.connect(func(): _cargar_slot(1))
	btn_slot_2.pressed.connect(func(): _cargar_slot(2))
	
	$MenuSlots/VBoxContainer/BtnAtras.pressed.connect(_on_btn_atras_pressed)
	
	menu_inicio.visible = true
	menu_slots.visible = false


func _on_btn_jugar_pressed():
	menu_inicio.visible = false
	menu_slots.visible = true
	
	actualizar_textos_slots()

func _on_btn_atras_pressed():
	menu_slots.visible = false
	menu_inicio.visible = true

func _on_btn_salir_pressed():
	get_tree().quit()


func _cargar_slot(numero_slot: int):
	print("Cargando Slot ", numero_slot)
	
	GM.partida_actual = numero_slot
	GM.cargar_partida()
	GM.cambiar_y_posicionar("res://scenes/Niveles/EscenaPrincipal.tscn", "InicioJuego")


func actualizar_textos_slots():
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
