extends CanvasLayer # (O extiende de Control, dependiendo de qué nodo sea la raíz)

@onready var btn_revivir = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BtnRevivir

func _ready():
	hide()
	btn_revivir.pressed.connect(_on_btn_revivir_pressed)

func mostrar_menu():
	show()
	get_tree().paused = true 
	
	btn_revivir.grab_focus()

func _on_btn_revivir_pressed():
	
	hide()
	
	get_tree().paused = false 
	GameManager.datos_jugador.vida_actual = GameManager.datos_jugador.vida_maxima
	var ruta_escena_casa = "res://scenes/Niveles/Pueblo/Props/CasaJugador/InteriorCasa.tscn" 

	var error = get_tree().change_scene_to_file(ruta_escena_casa)
