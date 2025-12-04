extends Node2D

#region Config

@export_group("Configuración de Salas")
@export var sala_inicio: PackedScene          
@export var salas_disponibles: Array[PackedScene]
@export var sala_boss: PackedScene            

@export_group("Opciones")
@export var longitud_mazmorra: int = 5      
#endregion

func _ready():
	if sala_inicio and not salas_disponibles.is_empty():
		generar_nivel()
	else:
		print("Faltan asignar escenas ")

func generar_nivel():
	
	# spawnear sala inciial
	var sala_actual = sala_inicio.instantiate()
	sala_actual.position = Vector2.ZERO # coordenada 0
	$CapaSalas.add_child(sala_actual)
	
	# spawnear salas medias
	for i in range(longitud_mazmorra):
		var escena_random = salas_disponibles.pick_random()
		var nueva_sala = escena_random.instantiate()
		

		if sala_actual.has_node("Salida"):
			var marker_salida = sala_actual.get_node("Salida")
			
			
			nueva_sala.position = sala_actual.position + marker_salida.position
		else:
			print(" La sala ", sala_actual.name, " no tiene  'Salida'.")
			break 
			
		add_child(nueva_sala)
		
		sala_actual = nueva_sala

	if sala_boss:
		var boss_room = sala_boss.instantiate()
		
		if sala_actual.has_node("Salida"):
			var marker = sala_actual.get_node("Salida")
			boss_room.position = sala_actual.position + marker.position
			add_child(boss_room)
		else:
			print("La última sala aleatoria no tenía salida, no se pudo poner al Boss.")

func _input(_event):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
