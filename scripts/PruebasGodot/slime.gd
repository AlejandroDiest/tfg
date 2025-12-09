extends CharacterBody2D

const SPEED = 40.0
const RANGO_VISION = 150.0 # Distancia en píxeles para detectarte
var vida = 2

# Variable para guardar quién es el jugador
var objetivo = null
var aturdido = false

func _physics_process(delta):
	if aturdido:
		# Hacemos que la velocidad baje poco a poco (fricción)
		velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		move_and_slide()
		return #
	# 1. BUSCAR AL JUGADOR (Si no lo tenemos ya fichado)
	if objetivo == null:
		var jugadores = get_tree().get_nodes_in_group("Jugador")
		if jugadores.size() > 0:
			objetivo = jugadores[0]
			
	# 2. COMPROBAR DISTANCIA Y PERSEGUIR
	if objetivo:
		# Calculamos la distancia real entre el slime y tú
		var distancia = global_position.distance_to(objetivo.global_position)
		
		# SOLO si estamos cerca, nos movemos
		if distancia < RANGO_VISION:
			var vector_direccion = (objetivo.global_position - global_position).normalized()
			velocity = vector_direccion * SPEED
			
			# Lógica de voltear sprite (Mirar al jugador)
			if $AnimatedSprite2D:
				if vector_direccion.x > 0:
					$AnimatedSprite2D.flip_h = false # Mirar derecha
				elif vector_direccion.x < 0:
					$AnimatedSprite2D.flip_h = true  # Mirar izquierda
		else:
			# Si te alejas demasiado, el slime frena
			velocity = Vector2.ZERO

	# 3. APLICAR MOVIMIENTO (Y CHOQUES)
	# move_and_slide usa la 'velocity' que hemos calculado arriba
	move_and_slide()

# --- LÓGICA DE RECIBIR DAÑO ---
func recibir_dano(cantidad, empuje: Vector2 = Vector2.ZERO):
	print("¡Slime herido!")
	vida -= cantidad
	aturdido=true
	# Empuje hacia atrás
	velocity += empuje * 150 
	move_and_slide()
	
	# Flash rojo
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	aturdido=false
	
	if vida <= 0:
		morir()

func morir():
	print("Slime eliminado")
	queue_free()
