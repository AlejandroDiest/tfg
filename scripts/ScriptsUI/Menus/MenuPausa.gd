extends CanvasLayer
const MENU_AJUSTES = preload("res://scenes/UI/Menus/MenuAjustes.tscn")

func _ready():
	$CenterContainer/PanelContainer/VBoxContainer/BtnAjustes.pressed.connect(_on_btn_ajustes_pressed)
	$CenterContainer/PanelContainer/VBoxContainer/BtnContinuar.pressed.connect(_on_btn_continuar_pressed)
	$CenterContainer/PanelContainer/VBoxContainer/BtnSalir.pressed.connect(_on_btn_salir_pressed)

func _on_btn_continuar_pressed():
	get_tree().paused = false
	queue_free()

func _on_btn_salir_pressed():
	GM.guardar_partida()
	get_tree().change_scene_to_file("res://scenes/UI/Menus/MenuInicio.tscn")
	queue_free()
	
func _on_btn_ajustes_pressed():
	var ajustes = MENU_AJUSTES.instantiate()
	get_parent().add_child(ajustes)
	ajustes.al_cerrar_ajustes.connect(_on_ajustes_cerrado)
	self.visible = false 
	

func _on_ajustes_cerrado():
	self.visible = true
	
func _input(event):
	if visible == false:
		return
	
	if event.is_action_pressed("escape"):
		_on_btn_continuar_pressed() 
		get_viewport().set_input_as_handled()
