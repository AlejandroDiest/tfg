extends CharacterBody2D

@export_group("Estadísticas")
@export var vida_maxima: int = 3
@export var velocidad: float = 60.0  
@export var empuje: float = 200.0

@export_group("IA")
@export var distancia_ataque: float = 40.0 
@export var distancia_disparo: float = 150.0 
@export var velocidad_deambular: float = 30.0 

@export_group("Combate a Distancia")
@export var escena_proyectil: PackedScene 

@export_group("Loot (Drops)")
@export var scene_drop : PackedScene 
@export var loot_item : Resource 
@export var drop_chance : float = 0.5 
@export var delay_drop: float = 0.0

var animacion_actual: String = ""
var vida_actual: int = 0
var objetivo: Node2D = null 
var esta_muerto: bool = false
var atacando: bool = false 
var herido: bool = false   
var direccion_deambular: Vector2 = Vector2.ZERO

# Variables de estado independientes
var puede_atacar_melee: bool = true
var puede_disparar: bool = true

@onready var timer_deambular = $TimerDeambular
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var timer_melee = $TimerMelee
@onready var timer_rango = $TimerRango

func _ready():
	vida_actual = vida_maxima
	
	# Conexiones independientes
	timer_melee.timeout.connect(func(): puede_atacar_melee = true)
	timer_rango.timeout.connect(func(): puede_disparar = true)
	
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)
	
	if not timer_deambular.timeout.is_connected(_on_timer_deambular_timeout):
		timer_deambular.timeout.connect(_on_timer_deambular_timeout)

	var area_deteccion = $AreaDeteccion 
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_area_deteccion_body_entered)
		area_deteccion.body_exited.connect(_on_area_deteccion_body_exited)
		
	_on_timer_deambular_timeout()

func _physics_process(_delta):
	if esta_muerto or atacando: 
		return
	
	if herido:
		velocity = velocity.move_toward(Vector2.ZERO, empuje * _delta * 5)
		move_and_slide()
		return

	if objetivo:
		var distancia = global_position.distance_to(objetivo.global_position)
		
		if distancia <= distancia_ataque:
			if puede_atacar_melee:
				_intentar_atacar_melee()
			else:
				if velocity.length() < 5: _reproducir_animacion("Idle")
		
		elif escena_proyectil != null and distancia <= distancia_disparo:
			if puede_disparar:
				disparar_proyectil()
			else:
				if velocity.length() < 5: _reproducir_animacion("Idle")
		
		else:
			_perseguir_jugador()
	else:
		_deambular()

	move_and_slide()
	_gestionar_giro_sprite()

func _perseguir_jugador():
	var direccion = global_position.direction_to(objetivo.global_position)
	velocity = direccion * velocidad
	_reproducir_animacion("Run")

func _intentar_atacar_melee():
	puede_atacar_melee = false
	timer_melee.start()
	atacar_cuerpo_a_cuerpo()

func atacar_cuerpo_a_cuerpo():
	atacando = true     
	anim.play("Attack")  

func disparar_proyectil():
	puede_disparar = false
	timer_rango.start()
		
	var proyectil = escena_proyectil.instantiate()
	proyectil.top_level = true
	var direccion_disparo = global_position.direction_to(objetivo.global_position)
	proyectil.global_position = global_position + (direccion_disparo * 20.0)
	
	if proyectil.has_method("configurar_proyectil"):
		proyectil.configurar_proyectil(direccion_disparo, self)
		
	proyectil.rotation = direccion_disparo.angle()
	get_parent().call_deferred("add_child", proyectil)

func recibir_daño(cantidad: int, direccion_empuje: Vector2 = Vector2.ZERO):
	if esta_muerto: return
	atacando = false 
	herido = true
	vida_actual -= cantidad
	velocity = direccion_empuje * empuje
	if vida_actual <= 0: morir()
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
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("AreaDeteccion"):
		$AreaDeteccion.set_deferred("monitoring", false)
	
	anim.play("Die")
	await anim.animation_finished
	intentar_soltar_loot()
	set_physics_process(false)
	
func _reproducir_animacion(nombre: String):
	if anim.current_animation == nombre and anim.is_playing():
		return
	anim.play(nombre)
func _gestionar_giro_sprite():
	if velocity.x > 0: sprite.flip_h = false
	elif velocity.x < 0: sprite.flip_h = true

func _on_animation_finished(anim_name):
	animacion_actual = "" 
	if anim_name == "Attack": 
		atacando = false 
	if anim_name == "Hurt": 
		herido = false     

func _on_area_deteccion_body_entered(body):
	if body.name == "Personaje": objetivo = body

func _on_area_deteccion_body_exited(body):
	if body == objetivo: objetivo = null

func intentar_soltar_loot():
	if scene_drop == null or loot_item == null: return
	if randf() <= drop_chance:
		var nuevo_drop = scene_drop.instantiate()
		nuevo_drop.item_data = loot_item
		nuevo_drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", nuevo_drop)
	
func _deambular():
	velocity = direccion_deambular * velocidad_deambular
	if velocity != Vector2.ZERO: _reproducir_animacion("Run")
	else: _reproducir_animacion("Idle")

func _on_timer_deambular_timeout():
	if randf() > 0.5: direccion_deambular = Vector2.ZERO
	else: direccion_deambular = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	timer_deambular.wait_time = randf_range(1.0, 3.0)
	timer_deambular.start()
