extends CanvasLayer

func _ready():
	$CenterContainer/PanelContainer/VBoxContainer/BtnContinuar.pressed.connect(_on_btn_continuar_pressed)
	$CenterContainer/PanelContainer/VBoxContainer/BtnSalir.pressed.connect(_on_btn_salir_pressed)

func _on_btn_continuar_pressed():
	get_tree().paused = false
	queue_free()

func _on_btn_salir_pressed():
	GM.guardar_partida()
	get_tree().change_scene_to_file("res://scenes/UI/MenuInicio.tscn")
	queue_free()

func _input(event):
	if event.is_action_pressed("escape"):
		print("Esc pretado en menu, intentnado cerrar")
		_on_btn_continuar_pressed() 
		get_viewport().set_input_as_handled()
