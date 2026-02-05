extends CharacterBody2D

@export var inventario : Inv
@export var velocidad: float = 180.0
@export var vida_maxima: int = 5

# --- VARIABLES DE ESTADO ---
var vida_actual: int = 0
var esta_atacando: bool = false
var esta_herido: bool = false
var esta_muerto: bool = false

# Variable para el Animation Canceling
var puede_cancelar_ataque: bool = false # <--- NUEVO: El interruptor mágico

# Referencias a los nodos hijos
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
# @onready var area_espada = $AreaEspada

func _ready():
	vida_actual = vida_maxima
	# Conectamos la señal para saber cuándo terminan los ataques o el daño
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Si estamos muertos, no hacemos nada más
	if esta_muerto:
		return

	# --- 1. LEER INPUT DE MOVIMIENTO ---
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# --- 2. LÓGICA DE CANCELACIÓN (LA MAGIA) ---
	# Si estamos atacando...
	if esta_atacando:
		# ...pero ya pasó el golpe (fase recovery) Y el jugador quiere moverse...
		if puede_cancelar_ataque and direccion != Vector2.ZERO:
			cancelar_ataque() # <--- ¡ROMPEMOS EL ATAQUE!
			# Y dejamos que el código siga hacia abajo para moverse inmediatamente
		else:
			# Si no podemos cancelar todavía, nos quedamos quietos
			velocity = Vector2.ZERO
			move_and_slide()
			return # <--- Cortamos aquí

	# Si estamos heridos, bloqueo total (sin cancelar)
	if esta_herido:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# --- 3. CONTROL DE MOVIMIENTO (Si llegamos aquí, es que podemos movernos) ---
	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		_actualizar_animacion("Run")
		_gestionar_giro_sprite(direccion.x)
	else:
		velocity = Vector2.ZERO
		_actualizar_animacion("Idle")

	move_and_slide()
	
	# --- 4. CONTROL DE NUEVO ATAQUE ---
	if Input.is_action_just_pressed("ataque"): 
		atacar()

# --- ACCIONES ---

func atacar():
	esta_atacando = true
	puede_cancelar_ataque = false # <--- NUEVO: Al empezar, estamos bloqueados
	# area_espada.monitoring = true 
	anim.play("Attack")

# <--- NUEVA FUNCIÓN: Llamada desde el AnimationPlayer (Call Method Track)
func permitir_cancelacion():
	puede_cancelar_ataque = true

# <--- NUEVA FUNCIÓN: Para forzar la salida del ataque (opcional, pero útil)
func cancelar_ataque():
	esta_atacando = false
	puede_cancelar_ataque = false
	# area_espada.monitoring = false # Importante apagar el daño si cancelas
	print("¡Ataque cancelado!")

func recibir_daño(cantidad: int):
	if esta_muerto or esta_herido: return
	
	vida_actual -= cantidad
	esta_herido = true
	esta_atacando = false 
	puede_cancelar_ataque = false # <--- NUEVO: Resetear por seguridad
	
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
	$CollisionShape2D.set_deferred("disabled", true)
	print("GAME OVER") 

# --- UTILIDADES ---

func _actualizar_animacion(nombre: String):
	# Evitamos reiniciar la animación si ya está sonando
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
		puede_cancelar_ataque = false # <--- NUEVO: Resetear
	
	if anim_name == "Hurt":
		esta_herido = false
