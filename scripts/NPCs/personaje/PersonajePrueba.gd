extends CharacterBody2D

@export var inventario : Inv
@export var velocidad: float = 180.0
@export var vida_maxima: int = 5

# --- HITBOX Y PIVOTE ---
@onready var pivot_ataque = $PivoteHitboxAtaque
# Cambiamos la referencia al Polygon2D
@onready var collision_hitbox = $PivoteHitboxAtaque/HitboxAtaque/PolygonHitbox

# --- VARIABLES DE ESTADO ---
var vida_actual: int = 0
var esta_atacando: bool = false
var esta_herido: bool = false
var esta_muerto: bool = false
var puede_cancelar_ataque: bool = false 

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	vida_actual = vida_maxima
	collision_hitbox.disabled = true
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if esta_muerto:
		return

	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# --- GESTIÓN DE ROTACIÓN ÚNICAMENTE IZQ / DER ---
	# Solo actualizamos el pivote si hay movimiento horizontal
	if direccion.x > 0:
		pivot_ataque.scale.x = 1   # Escala normal, mira a la derecha
	elif direccion.x < 0:
		pivot_ataque.scale.x = -1  # Escala invertida, mira a la izquierda

	if esta_atacando:
		if puede_cancelar_ataque and direccion != Vector2.ZERO:
			cancelar_ataque() 
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			return 

	if esta_herido:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		_actualizar_animacion("Run")
		_gestionar_giro_sprite(direccion.x)
	else:
		velocity = Vector2.ZERO
		_actualizar_animacion("Idle")

	move_and_slide()
	var fuerza_choque = 60.0 # Ajusta esto para que el enemigo sea más "pesado" o "ligero"
	
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var cuerpo_colisionado = colision.get_collider()
		
		if cuerpo_colisionado.is_in_group("Enemigo"):
			# Empujamos al enemigo usando la normal de la colisión (dirección opuesta al choque)
			cuerpo_colisionado.velocity = -colision.get_normal() * fuerza_choque
			# Le pedimos al enemigo que procese ese movimiento
			cuerpo_colisionado.move_and_slide()
	
	if Input.is_action_just_pressed("ataque"): 
		atacar()

# --- ACCIONES ---
func recolectar(item: InvItem):
	if inventario:
		inventario.insertar(item)
		print("Has recogido: ", item.nombreItem)
	else:
		print("ERROR: El jugador no tiene un inventario asignado en el Inspector")
		
func atacar():
	if esta_atacando or esta_herido: return
	
	esta_atacando = true
	puede_cancelar_ataque = false 
	anim.play("Attack")
	
	# --- LÓGICA DE DAÑO ---
	# Usamos set_deferred para evitar errores de físicas al activar/desactivar
	collision_hitbox.set_deferred("disabled", false)
	
	# Esperamos un frame para que las físicas detecten el área nueva
	await get_tree().physics_frame
	
	var area_daño = $PivoteHitboxAtaque/HitboxAtaque
	var cuerpos_alcanzados = area_daño.get_overlapping_bodies()
	
	for cuerpo in cuerpos_alcanzados:
		# Cambia "enemigos" por "Enemigo" (Exactamente como lo tienes en tu grupo)
		if cuerpo.is_in_group("Enemigo") and cuerpo.has_method("recibir_daño"):
			var direccion_golpe = (cuerpo.global_position - global_position).normalized()
			
			cuerpo.recibir_daño(1, direccion_golpe)
	
	# Tiempo que el arco de la espada es "dañino"
	await get_tree().create_timer(0.15).timeout
	collision_hitbox.set_deferred("disabled", true)

func permitir_cancelacion():
	puede_cancelar_ataque = true

func cancelar_ataque():
	esta_atacando = false
	puede_cancelar_ataque = false
	collision_hitbox.set_deferred("disabled", true)
	print("¡Ataque cancelado!")

func recibir_daño(cantidad: int):
	if esta_muerto or esta_herido: return
	
	vida_actual -= cantidad
	esta_herido = true
	esta_atacando = false 
	puede_cancelar_ataque = false
	collision_hitbox.set_deferred("disabled", true)
	
	if vida_actual <= 0:
		morir()
	else:
		anim.play("Hurt")
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE

func morir():
	esta_muerto = true
	anim.play("Die")
	collision_hitbox.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)

# --- UTILIDADES ---

func _actualizar_animacion(nombre: String):
	if anim.current_animation != nombre:
		anim.play(nombre)

func _gestionar_giro_sprite(direccion_x):
	if direccion_x > 0:
		sprite.flip_h = false
	elif direccion_x < 0:
		sprite.flip_h = true

func _on_animation_finished(anim_name):
	if anim_name == "Attack":
		esta_atacando = false
		puede_cancelar_ataque = false
		collision_hitbox.set_deferred("disabled", true)
	
	if anim_name == "Hurt":
		esta_herido = false
