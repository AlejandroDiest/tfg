extends Control

@onready var boton_respawn = $VBoxContainer/ButtonRespawn
@onready var boton_continuar = $VBoxContainer/ButtonContinuar

func _ready():
	boton_respawn.pressed.connect(_respawn_activado)
	boton_continuar.pressed.connect(_continuar_activado)

func _respawn_activado():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _continuar_activado():
	get_tree().paused = false
	visible = false
