extends CanvasLayer

signal al_cerrar_ajustes 
@onready var slider_musica = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FilaMusica/SliderMusica
var bus_index_musica : int

func _ready():
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BtnVolver.pressed.connect(_on_btn_volver_pressed)
	bus_index_musica = AudioServer.get_bus_index("Musica")
	var volumen_db = AudioServer.get_bus_volume_db(bus_index_musica)
	slider_musica.value = db_to_linear(volumen_db)
	

func _on_slider_musica_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_musica, linear_to_db(value))
	
	AudioServer.set_bus_mute(bus_index_musica, value < 0.05)
		
func _on_btn_volver_pressed():
	al_cerrar_ajustes.emit()
	queue_free()

func _input(event):
	if event.is_action_pressed("escape"): 
		_on_btn_volver_pressed()
		get_viewport().set_input_as_handled()
