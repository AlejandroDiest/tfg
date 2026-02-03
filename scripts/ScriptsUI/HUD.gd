extends CanvasLayer

@onready var contenedor_corazones: HBoxContainer = $VBoxContainer/ContenedorCorazones
@onready var texto_oro: Label = $VBoxContainer/ContenedorOro/Control/CantOro


var corazon_lleno_scene = preload("res://scenes/UI/HUD/Corazon.tscn")
var corazon_vacio_scene = preload("res://scenes/UI/HUD/CorazonVacio.tscn")


func _process(_delta: float) -> void:
	actualizar_oro()
	actualizar_vida()
	
func actualizar_oro():
	texto_oro.text = str(GM.datos_jugador.oro)

func actualizar_vida():
	
	for corazon in contenedor_corazones.get_children():
		corazon.queue_free()

	var vida_actual = GM.datos_jugador.vida_actual
	var vida_maxima = GM.datos_jugador.vida_maxima
	var corazones_vacios_a_añadir = vida_maxima - vida_actual
	
	for i in range(vida_actual):
		var corazon = corazon_lleno_scene.instantiate()
		contenedor_corazones.add_child(corazon)

	for i in range(corazones_vacios_a_añadir):
		var corazon = corazon_vacio_scene.instantiate() 
		contenedor_corazones.add_child(corazon)
