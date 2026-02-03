extends CharacterBody2D

@export var inventario : Inv
@export var velocidad: float = 180.0
@export var vida_maxima: int = 5

# --- VARIABLES DE ESTADO ---
var vida_actual: int = 0
var esta_atacando: bool = false
var esta_herido: bool = false
var esta_muerto: bool = false

# Referencias a los nodos hijos
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
# @onready var area_espada = $AreaEspada # Descomenta esto cuando crees el Area2D del arma

func _ready():
	vida_actual = vida_maxima
	# Conectamos la señal para saber cuándo terminan los ataques o el daño
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Si estamos muertos, no hacemos nada más
	if esta_muerto:
		return

	# Si estamos atacando o heridos, NO nos movemos (bloqueo de movimiento)
	if esta_atacando or esta_herido:
		velocity = Vector2.ZERO # Frenar en seco
		move_and_slide()
		return

	# --- CONTROL DE MOVIMIENTO ---
	# Obtenemos la dirección pulsada (teclas flechas o WASD)
	# Esto devuelve un Vector (ej: (1, 0) si vas a la derecha)
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		_actualizar_animacion("Run")
		_gestionar_giro_sprite(direccion.x)
	else:
		velocity = Vector2.ZERO
		_actualizar_animacion("Idle")

	move_and_slide()
	
	# --- CONTROL DE ATAQUE ---
# Cambia "atacar" por "ui_accept"
	if Input.is_action_just_pressed("ui_accept"): 
		atacar()

# --- ACCIONES ---

func atacar():
	esta_atacando = true
	# Aquí podrías activar el colisionador de la espada:
	# area_espada.monitoring = true 
	anim.play("Attack")

func recibir_daño(cantidad: int):
	if esta_muerto or esta_herido: return
	
	vida_actual -= cantidad
	esta_herido = true
	esta_atacando = false # Si te pegan, se corta tu ataque
	
	if vida_actual <= 0:
		morir()
	else:
		anim.play("Hurt")
		# Efecto visual de parpadeo rojo (Feedback)
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE

func morir():
	esta_muerto = true
	anim.play("Die")
	$CollisionShape2D.set_deferred("disabled", true)
	print("GAME OVER") 

# --- UTILIDADES ---

func _actualizar_animacion(nombre: String):
	if anim.current_animation != nombre:
		anim.play(nombre)

func _gestionar_giro_sprite(direccion_x):
	if direccion_x > 0:
		sprite.flip_h = false
	elif direccion_x < 0:
		sprite.flip_h = true

func recolectar(item):
	inventario.insertar(item)
# --- SEÑALES ---

func _on_animation_finished(anim_name):
	if anim_name == "Attack":
		esta_atacando = false
	
	if anim_name == "Hurt":
		esta_herido = false
		
		
