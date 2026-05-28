extends CanvasLayer

signal al_cerrar_ajustes 

@onready var slider_musica = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FilaMusica/SliderMusica
@onready var slider_vfx = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FilaVFX/SliderVFX

var bus_index_musica : int
var bus_index_vfx : int

func _ready():
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BtnVolver.pressed.connect(_on_btn_volver_pressed)
	
	bus_index_musica = AudioServer.get_bus_index("Musica")
	var volumen_db_musica = AudioServer.get_bus_volume_db(bus_index_musica)
	slider_musica.value = db_to_linear(volumen_db_musica)
	
	bus_index_vfx = AudioServer.get_bus_index("VFX")
	var volumen_db_vfx = AudioServer.get_bus_volume_db(bus_index_vfx)
	slider_vfx.value = db_to_linear(volumen_db_vfx)

func _on_slider_musica_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_musica, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index_musica, value < 0.05)
	GameManager.datos_jugador["volumen_musica"] = value

func _on_slider_vfx_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index_vfx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index_vfx, value < 0.05)
	GameManager.datos_jugador["volumen_vfx"] = value
		
func _on_btn_volver_pressed():
	al_cerrar_ajustes.emit()
	queue_free()

func _input(event):
	if event.is_action_pressed("escape"): 
		_on_btn_volver_pressed()
		get_viewport().set_input_as_handled()
