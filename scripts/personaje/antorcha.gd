extends PointLight2D

# Configuración del parpadeo
var energia_base = 1.5
var variacion = 0.1
var velocidad = 6.0
var tiempo = 0.0

func _process(delta):
	tiempo += delta * velocidad
	var ruido = sin(tiempo) * variacion + (randf() * 0.1)
	energy = energia_base + ruido
