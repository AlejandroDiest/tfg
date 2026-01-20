extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_group("Estadísticas")
@export var vida_maxima: int = 3
@export var velocidad: float = 60.0 # 
@export var empuje: float = 200.0

@export_group("IA")
@export var distancia_ataque: float = 30.0 
@export var velocidad_deambular: float = 30.0 

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
	# Así nos aseguramos de que los "ojos" funcionen siempre
	var area_deteccion = $AreaDeteccion # Asegúrate que el nodo se llama así
	if not area_deteccion.body_entered.is_connected(_on_area_deteccion_body_entered):
		area_deteccion.body_entered.connect(_on_area_deteccion_body_entered)
	
	if not area_deteccion.body_exited.is_connected(_on_area_deteccion_body_exited):
		area_deteccion.body_exited.connect(_on_area_deteccion_body_exited)
		
	# Arrancamos el patrullaje manual la primera vez
	_on_timer_deambular_timeout()

		
func _physics_process(_delta):
	if esta_muerto or atacando or herido: 
		return
	
	if objetivo:
		# PRIORIDAD 1: Si veo al jugador, le persigo
		var distancia = global_position.distance_to(objetivo.global_position)
		if distancia > distancia_ataque:
			_perseguir_jugador()
		else:
			_intentar_atacar()
	else:
		# PRIORIDAD 2: Si no veo a nadie, patrullo relajado
		_deambular()  # <--- NUEVA FUNCIÓN

	move_and_slide()
	_gestionar_giro_sprite()

# --- COMPORTAMIENTOS ---

func _perseguir_jugador():
	# SOLUCIÓN 1: Movimiento Directo (Sin NavigationAgent por ahora)
	var direccion = global_position.direction_to(objetivo.global_position)
	velocity = direccion * velocidad
	_reproducir_animacion("Run")

func _intentar_atacar():
	velocity = Vector2.ZERO # Frenar en seco
	
	if puede_atacar:
		atacar()
	else:
		# Si estoy en enfriamiento (cooldown), me quedo quieto mirando
		_reproducir_animacion("Idle")

func atacar():
	atacando = true      # BLOQUEO: "Estoy ocupado"
	puede_atacar = false # COOLDOWN: "Gasto mi turno"
	anim.play("Attack")  # Forzamos la animación (sin usar _reproducir)

func recibir_daño(cantidad: int, direccion_empuje: Vector2 = Vector2.ZERO):
	if esta_muerto: return
	
	# SOLUCIÓN 2: Interrumpir ataque si me pegan
	atacando = false 
	herido = true
	
	vida_actual -= cantidad
	velocity = direccion_empuje * empuje
	move_and_slide() # Aplicar el empuje inmediatamente
	
	if vida_actual <= 0:
		morir()
	else:
		anim.play("Hurt") # Forzamos animación de dolor
		
		# Efecto visual rojo
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE

func morir():
	esta_muerto = true
	atacando = false
	herido = false
	velocity = Vector2.ZERO
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	anim.play("Die")
	
	await anim.animation_finished

	set_physics_process(false)

# --- UTILIDADES ---

func _reproducir_animacion(nombre: String):
	# Solo cambia si no está sonando ya, para evitar "tartamudeo"
	if anim.current_animation != nombre:
		anim.play(nombre)

func _gestionar_giro_sprite():
	if velocity.x > 0: sprite.flip_h = false
	elif velocity.x < 0: sprite.flip_h = true

# --- SEÑALES ---

# SOLUCIÓN 3: Esta función desbloquea al monstruo cuando termina la animación
func _on_animation_finished(anim_name):
	if anim_name == "Attack":
		atacando = false      # ¡Ya he terminado el golpe!
		timer_ataque.start()  # Ahora empieza el tiempo de espera
	
	if anim_name == "Hurt":
		herido = false        # Ya me he recuperado del golpe

func _on_area_deteccion_body_entered(body):
	if body.name == "Personaje":
		objetivo = body

func _on_area_deteccion_body_exited(body):
	if body == objetivo:
		objetivo = null

func _on_timer_ataque_timeout():
	puede_atacar = true
	
	
func _deambular():
	# Aplicamos movimiento en la dirección aleatoria actual
	velocity = direccion_deambular * velocidad_deambular
	
	if velocity != Vector2.ZERO:
		_reproducir_animacion("Run")
	else:
		_reproducir_animacion("Idle")

func _on_timer_deambular_timeout():
	# Este es el "Cerebro Indeciso"
	
	# 1. Decidir dirección
	if randf() > 0.5:
		direccion_deambular = Vector2.ZERO
	else:
		direccion_deambular = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
	# 2. Cambiar el tiempo para la PRÓXIMA decisión
	timer_deambular.wait_time = randf_range(1.0, 3.0)
	
	# 3. --- CORRECCIÓN CRÍTICA: Forzar el reinicio ---
	# Esto asegura que el bucle continúe infinitamente
	timer_deambular.start()
	
func _input(event):
	if event.is_action_pressed("ui_accept"): # Espacio
		recibir_daño(1)


func _on_area_ataque_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_ataque_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
