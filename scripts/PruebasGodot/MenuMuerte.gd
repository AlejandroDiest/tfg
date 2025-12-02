extends Control

@onready var boton_respawn = $VBoxContainer/ButtonRespawn
@onready var boton_salir = $VBoxContainer/ButtonSalir

func _ready():
	boton_respawn.pressed.connect(_respawn_activado)
	boton_salir.pressed.connect(_salir_activado)

func _respawn_activado():
	get_tree().paused = false
	GM.respawnear()
	get_tree().reload_current_scene()

func _salir_activado():
	get_tree().quit()
