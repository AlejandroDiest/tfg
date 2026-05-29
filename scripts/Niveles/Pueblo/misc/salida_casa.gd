extends Area2D

@export var ruta: String 

@export var nombre_marker_destino: String = ""

		
func _on_body_entered(body: Node2D) -> void:
	print("\n--- ALERTA DE PUERTA ---")
	print("1. Algo ha pisado la puerta. Se llama: ", body.name)
	print("2. Sus grupos son: ", body.get_groups())
	
	if "Personaje" in body.name or body.is_in_group("player"):
		print("3. ¡Jugador detectado! Intentando viaje...")
		
		if SceneManager.get("viajando") == true:
			print("4. AVISO: El SceneManager estaba atascado. Forzando desbloqueo.")
			SceneManager.viajando = false
			
		if ruta != null:
			print("5. Viajando a la ruta: ", ruta, " | Marker: ", nombre_marker_destino)
			SceneManager.cambiar_y_posicionar(ruta, nombre_marker_destino)
		else:
			print("ERROR CRÍTICO: El Inspector de esta puerta está vacío.")
	else:
		print("3. No es el jugador, es solo decorado. Lo ignoro.")
