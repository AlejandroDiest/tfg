extends Node2D

# --- CONFIGURACIÓN EN EL INSPECTOR ---
@export_group("Generación")
@export var cantidad_min: int = 1      # Mínimo de flores por tile
@export var cantidad_max: int = 3      # Máximo de flores por tile
@export var dispersion_x: float = 10.0 # Cuánto se separan a lo ancho
@export var dispersion_y: float = 10.0  # Cuánto se separan a lo alto (menos que X por la perspectiva)

@export_group("Variación Visual")
@export var variar_velocidad: bool = true
@export var variar_flip: bool = true   # Voltear espejo aleatoriamente
@export var variar_frame: bool = true  # Empezar en frame distinto

# --- REFERENCIAS INTERNAS ---
# IMPORTANTE: Asegúrate de que tu sprite hijo se llama "AnimatedSprite2D"
# o cambia este nombre por el que tenga tu nodo.
@onready var molde_flor: AnimatedSprite2D = $Hierba 

func _ready():
	# 1. Configuración obligatoria para que no se pisen mal
	y_sort_enabled = true 
	
	# Verificación de seguridad
	if not molde_flor:
		push_error("¡ERROR! No encuentro el nodo 'AnimatedSprite2D' dentro de " + name)
		return

	# 2. Ocultamos el molde original (el del centro)
	# No lo borramos aún porque lo necesitamos para copiarlo
	molde_flor.visible = false
	
	# 3. Decidimos cuántas flores nacen en este tile
	var cantidad_final = randi_range(cantidad_min, cantidad_max)
	
	# 4. Bucle de creación
	for i in range(cantidad_final):
		crear_flor()
		
	# 5. Ya no necesitamos el molde original, lo borramos para limpiar memoria
	# (Usamos call_deferred para evitar errores durante el _ready)
	molde_flor.queue_free()

func crear_flor():
	# A. Duplicar el molde
	var nueva_flor = molde_flor.duplicate()
	nueva_flor.visible = true # Hacemos visible la copia
	
	# B. Posición Aleatoria (Elipse)
	var pos_x = randf_range(-dispersion_x, dispersion_x)
	var pos_y = randf_range(-dispersion_y, dispersion_y)
	nueva_flor.position = Vector2(pos_x, pos_y)
	
	# C. Variaciones Visuales (El toque de calidad)
	if variar_frame and nueva_flor.sprite_frames:
		# Reproducir y saltar a un frame aleatorio
		nueva_flor.play()
		var total_frames = nueva_flor.sprite_frames.get_frame_count(nueva_flor.animation)
		nueva_flor.frame = randi() % total_frames
	
	if variar_velocidad:
		# Velocidad entre 80% y 120% de la original
		nueva_flor.speed_scale = randf_range(0.8, 1.2)
		
	if variar_flip:
		# 50% de probabilidad de voltearse horizontalmente
		if randf() > 0.5:
			nueva_flor.flip_h = !nueva_flor.flip_h

	# D. Añadir a la escena
	add_child(nueva_flor)
