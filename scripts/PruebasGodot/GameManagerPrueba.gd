extends Node

var hp = 3
var score = 0

@onready var label_vida = $"../CanvasLayer/LabelVida"
@onready var win: Control = $"../CanvasLayer/Win"
@onready var muerte: Control = $"../CanvasLayer/Muerte"


func _ready():
	label_vida.text = "Vidas " +str(hp)
	

func add_score():
	score += 1
	if(score == 3):
		print("Has ganado")
		show_win_menu()
	
func show_win_menu():
	win.visible = true
	get_tree().paused = true

func remove_hp() -> void:
	hp = hp - 1
	print("David ha recibido daño, ahora tiene ", hp, " de vida.")
	label_vida.text = "Vidas " +str(hp)
	if(hp == 0):
		print("David ha muerto O7")       
		show_death_menu()

func show_death_menu():
	muerte.visible = true
	get_tree().paused = true  
	
	

	
