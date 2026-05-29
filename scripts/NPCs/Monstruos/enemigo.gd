extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_group("Estadísticas")
@export var vida_maxima: int = 3
@export var velocidad: float = 60.0 # 
@export var empuje: float = 200.0

@export_group("IA")
@export var distancia_ataque: float = 30.0 
@export var velocidad_deambular: float = 30.0 

@export_group("Loot (Drops)")
@export var scene_drop : PackedScene 
@export var loot_item : InvItem      
@export var drop_chance : float = 0.5 
@export var delay_drop: float = 0.0 # NUEVO: Tiempo de espera extra tras morir

var vida_actual: int = 0
var objetivo: Node2D = null 
var puede_atacar: bool = true
var esta_muerto: bool = false
var atacando: bool = false 
var herido: bool = false   
var direccion_deambular: Vector2 = Vector2.ZERO

@onready var timer_deambular = $TimerDeambular
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var timer_ataque = $TimerAtaque

func _ready():
	vida_actual = vida_maxima

	# 1. Conectar Animaciones
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)
	
	# 2. Conectar Timer Ataque
	if not timer_ataque.timeout.is_connected(_on_timer_ataque_timeout):
		timer_ataque.timeout.connect(_on_timer_ataque_timeout)
		
	# 3. Conectar Timer Deambular
	if not timer_deambular.timeout.is_connected(_on_timer_deambular_timeout):
		timer_deambular.timeout.connect(_on_timer_deambular_timeout)

	# --- CORRECCIÓN CRÍTICA: Conectar la Detección por Código ---
	var area_deteccion = $AreaDeteccion 
	if not area_deteccion.body_entered.is_connected(_on_area_deteccion_body_entered):
		area_deteccion.body_entered.connect(_on_area_deteccion_body_entered)
	
	if not area_deteccion.body_exited.is_connected(_on_area_deteccion_body_exited):
		area_deteccion.body_exited.connect(_on_area_deteccion_body_exited)
		
	# Arrancamos el patrullaje manual la primera vez
	_on_timer_deambular_timeout()

		
func _physics_process(_delta):
	if esta_muerto or atacando: 
		return
	
	# --- NUEVO LÓGICA DE KNOCKBACK ---
	if herido:
		velocity = velocity.move_toward(Vector2.ZERO, empuje * _delta * 5)
		move_and_slide()
		return

	if objetivo:
		var distancia = global_position.distance_to(objetivo.global_position)
		if distancia > distancia_ataque:
			_perseguir_jugador()
		else:
			_intentar_atacar()
	else:
		_deambular()

	move_and_slide()
	_gestionar_giro_sprite()

# --- COMPORTAMIENTOS ---

func _perseguir_jugador():
	var direccion = global_position.direction_to(objetivo.global_position)
	velocity = direccion * velocidad
	_reproducir_animacion("Run")

func _intentar_atacar():
	velocity = Vector2.ZERO
	
	if puede_atacar:
		atacar()
	else:
		_reproducir_animacion("Idle")

func atacar():
	atacando = true      
	puede_atacar = false 
	anim.play("Attack")  

func recibir_daño(cantidad: int, direccion_empuje: Vector2 = Vector2.ZERO):
	if esta_muerto: return
	
	atacando = false 
	herido = true
	vida_actual -= cantidad
	
	velocity = direccion_empuje * empuje
	
	if vida_actual <= 0:
		morir()
	else:
		anim.play("Hurt")
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE

func morir():
	esta_muerto = true
	atacando = false
	herido = false
	velocity = Vector2.ZERO
	
	# Desactivar físicas de forma segura
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Avisar al GameManager si es el Zombie de la misión
	# Solo ejecutamos esto si estamos matando al EnemigoBase del Cementerio
	if name == "Enemigobase":
		if GameManager.estado_cementerio == GameManager.EstadoCementerio.ZOMBIE:
			GameManager.estado_cementerio = GameManager.EstadoCementerio.VERJA
	
	# Reproducir animación
	anim.play("Die")
	
	# Esperar a que termine la animación
	await anim.animation_finished

	if delay_drop > 0.0:
		await get_tree().create_timer(delay_drop).timeout

	intentar_soltar_loot()
	
	set_physics_process(false)

# --- UTILIDADES ---

func _reproducir_animacion(nombre: String):
	if anim.current_animation != nombre:
		anim.play(nombre)

func _gestionar_giro_sprite():
	if velocity.x > 0: sprite.flip_h = false
	elif velocity.x < 0: sprite.flip_h = true

# --- SEÑALES ---

func _on_animation_finished(anim_name):
	if anim_name == "Attack":
		atacando = false     
		timer_ataque.start() 
	
	if anim_name == "Hurt":
		herido = false       

func _on_area_deteccion_body_entered(body):
	if body.name == "Personaje":
		objetivo = body

func _on_area_deteccion_body_exited(body):
	if body == objetivo:
		objetivo = null

func _on_timer_ataque_timeout():
	puede_atacar = true
	
func intentar_soltar_loot():
	if scene_drop == null or loot_item == null:
		return
	
	if randf() <= drop_chance:
		var nuevo_drop = scene_drop.instantiate()
		nuevo_drop.item_data = loot_item
		nuevo_drop.global_position = global_position
		
		get_parent().add_child(nuevo_drop)
	
func _deambular():
	velocity = direccion_deambular * velocidad_deambular
	
	if velocity != Vector2.ZERO:
		_reproducir_animacion("Run")
	else:
		_reproducir_animacion("Idle")

func _on_timer_deambular_timeout():
	if randf() > 0.5:
		direccion_deambular = Vector2.ZERO
	else:
		direccion_deambular = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
	timer_deambular.wait_time = randf_range(1.0, 3.0)
	timer_deambular.start()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		recibir_daño(1)

func _on_area_ataque_body_entered(body: Node2D) -> void:
	pass

func _on_area_ataque_body_exited(body: Node2D) -> void:
	pass
