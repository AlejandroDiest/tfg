extends CharacterBody2D

@onready var arma = $Espada # Asegúrate que el nodo hijo se llama "Espada"
@onready var sprite_personaje = $SpritePersonaje # Tu AnimatedSprite2D

const SPEED =120.0
var atacando: bool = false
var ultima_direccion: String = "Abajo" # Por defecto

func _input(event):
	# Si atacamos con clic izquierdo
	if event.is_action_pressed("ataque") and not atacando:
		realizar_ataque()

func _physics_process(_delta):
	# Si estamos atacando, no nos movemos (opcional, pero recomendado)
	if atacando:
		return

	# 1. MOVIMIENTO
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_vector.length() > 0:
		velocity = input_vector.normalized() * SPEED
		
		# 2. DECIDIR DIRECCIÓN (Sin usar scale ni flips)
		if abs(input_vector.x) > abs(input_vector.y):
			# Movimiento Horizontal
			if input_vector.x > 0: ultima_direccion = "Dcha"
			else: ultima_direccion = "Izq"
		else:
			# Movimiento Vertical
			if input_vector.y > 0: ultima_direccion = "Abajo"
			else: ultima_direccion = "Arriba"
			
		# Reproducir animación de andar
		sprite_personaje.play("Mover" + ultima_direccion)
	else:
		# Frenar
		velocity = Vector2.ZERO
		sprite_personaje.stop()
		sprite_personaje.frame = 0 # Quedarse quieto en el primer frame

	move_and_slide()

func realizar_ataque():
	atacando = true
	velocity = Vector2.ZERO # Frenar en seco
	
	# 1. Calcular dirección hacia el ratón
	var mouse_pos = get_global_mouse_position()
	var vector_ataque = (mouse_pos - global_position).normalized()
	
	# 2. Convertir vector a texto (Dcha, Izq...) para el CUERPO
	var angulo = vector_ataque.angle()
	var angulo_snapped = snapped(angulo, PI/2)
	var grados = int(rad_to_deg(angulo_snapped))
	if grados == -180: grados = 180
	
	var dir_string = "Abajo" # Valor por defecto
	match grados:
		0: dir_string = "Dcha"
		90: dir_string = "Abajo"
		180: dir_string = "Izq"
		-90: dir_string = "Arriba"
	
	# 3. REPRODUCIR ANIMACIÓN DEL CUERPO (¡Esto es lo que faltaba!)
	# Asegúrate de tener: PegarDcha, PegarIzq, PegarArriba, PegarAbajo en el personaje
	sprite_personaje.play("Pegar" + dir_string)
	
	# 4. ORDENAR A LA ESPADA QUE ATAQUE
	# La espada se encargará de su propia animación y hitbox
	await arma.atacar(vector_ataque)
	
	# 5. AL TERMINAR
	atacando = false
	# Volvemos a la animación de estar quieto mirando en esa dirección
	sprite_personaje.play("Mover" + dir_string)
	sprite_personaje.stop()
	sprite_personaje.frame = 0
