extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var hitbox_area = $AreaEspada
@onready var hitbox_colision = $AreaEspada/CollisionShape2D

@export var damage: int = 1

func _ready():
	hitbox_colision.disabled = true # Empezar desactivada

# Esta función devuelve una señal (await) para que el player sepa cuándo terminar
func atacar(vector_direccion: Vector2):
	# 1. CALCULAR ÁNGULO (0, 90, 180, -90)
	var angulo = vector_direccion.angle()
	var angulo_snapped = snapped(angulo, PI/2)
	var grados = int(rad_to_deg(angulo_snapped))
	
	# Corrección para que -180 sea 180 (Izquierda)
	if grados == -180: grados = 180

	# 2. CONFIGURAR ANIMACIÓN Y HITBOX
	# Aquí NO rotamos el dibujo, elegimos la animación correcta.
	# PERO sí rotamos el "AreaEspada" para que la caja de colisión cuadre.
	
	match grados:
		0: # DERECHA
			anim.play("PegarDcha")
			hitbox_area.rotation_degrees = 0 
		90: # ABAJO
			anim.play("PegarAbajo")
			hitbox_area.rotation_degrees = 90
		180: # IZQUIERDA
			anim.play("PegarIzq")
			hitbox_area.rotation_degrees = 180
		-90: # ARRIBA
			anim.play("PegarArriba")
			hitbox_area.rotation_degrees = -90

	# 3. ACTIVAR DAÑO
	hitbox_colision.set_deferred("disabled", false)
	
	# Esperar a que termine la animación
	await anim.animation_finished
	
	# 4. DESACTIVAR DAÑO
	hitbox_colision.set_deferred("disabled", true)

# SEÑAL body_entered (Conéctala desde el editor a este nodo)
func _on_area_espada_body_entered(body):
	if body.is_in_group("Enemigos"):
		var vector_empuje = (body.global_position - global_position).normalized()
		
		if body.has_method("recibir_dano"):
			body.recibir_dano(damage, vector_empuje)
			
			
