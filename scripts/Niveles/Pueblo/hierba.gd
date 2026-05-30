extends Node2D

@export_group("Generación")
@export var cantidad_min: int = 1      
@export var cantidad_max: int = 3     
@export var dispersion_x: float = 10.0
@export var dispersion_y: float = 10.0 

@export_group("Variación Visual")
@export var variar_velocidad: bool = true
@export var variar_flip: bool = true  
@export var variar_frame: bool = true  


@onready var molde_flor: AnimatedSprite2D = $Hierba 

func _ready():
	y_sort_enabled = true 
	
	if not molde_flor:
		push_error("¡ERROR! No encuentro el nodo 'AnimatedSprite2D' dentro de " + name)
		return

	molde_flor.visible = false
	
	var cantidad_final = randi_range(cantidad_min, cantidad_max)
	
	for i in range(cantidad_final):
		crear_flor()
		
	molde_flor.queue_free()

func crear_flor():
	var nueva_flor = molde_flor.duplicate()
	nueva_flor.visible = true 
	
	var pos_x = randf_range(-dispersion_x, dispersion_x)
	var pos_y = randf_range(-dispersion_y, dispersion_y)
	nueva_flor.position = Vector2(pos_x, pos_y)
	
	if variar_frame and nueva_flor.sprite_frames:
		nueva_flor.play()
		var total_frames = nueva_flor.sprite_frames.get_frame_count(nueva_flor.animation)
		nueva_flor.frame = randi() % total_frames
	
	if variar_velocidad:
		nueva_flor.speed_scale = randf_range(0.8, 1.2)
		
	if variar_flip:
		if randf() > 0.5:
			nueva_flor.flip_h = !nueva_flor.flip_h

	add_child(nueva_flor)
