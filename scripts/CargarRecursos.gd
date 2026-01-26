extends Control

@onready var barra = $ProgressBar 
# Asegúrate de que tu nodo de barra se llame ProgressBar o cambia el nombre aquí

# LISTA DE LA COMPRA: ¿Qué escenas quieres guardar en la mochila?
var lista_de_carga = [
	# CAMBIA ESTAS RUTAS POR LAS TUYAS EXACTAS
	{ "ruta": "res://scenes/Niveles/Pueblo/Pueblo.tscn", "tipo": "Pueblo" },
	{ "ruta": "res://scenes/Niveles/Cripta/Cripta.tscn", "tipo": "Cripta" },
	{ "ruta": "res://scenes/UI/MenuInicio.tscn", "tipo": "Menu" }
]

var indice_actual: int = 0

func _ready():
	print("--- INICIANDO CARGA MASIVA ---")
	barra.value = 0
	barra.max_value = lista_de_carga.size() * 100 
	
	iniciar_carga_siguiente()

func iniciar_carga_siguiente():
	if indice_actual >= lista_de_carga.size():
		terminar_carga()
		return
	
	var ruta = lista_de_carga[indice_actual]["ruta"]
	var error = ResourceLoader.load_threaded_request(ruta)
	
	if error != OK:
		print("ERROR FATAL: No se encuentra la ruta: ", ruta)
		indice_actual += 1
		iniciar_carga_siguiente()

func _process(delta):
	if indice_actual >= lista_de_carga.size(): return
	
	var ruta = lista_de_carga[indice_actual]["ruta"]
	var progreso = []
	var estado = ResourceLoader.load_threaded_get_status(ruta, progreso)
	
	var porcentaje_item = 0.0
	if progreso.size() > 0: porcentaje_item = progreso[0]
	
	var valor_objetivo = (indice_actual * 100) + (porcentaje_item * 100)
	barra.value = move_toward(barra.value, valor_objetivo, delta * 200)
	
	if estado == ResourceLoader.THREAD_LOAD_LOADED:
		var recurso_cargado = ResourceLoader.load_threaded_get(ruta)
		var tipo = lista_de_carga[indice_actual]["tipo"]
		
		print("Cargado: ", tipo)
		guardar_en_mochila(tipo, recurso_cargado)
		
		indice_actual += 1
		iniciar_carga_siguiente()

func guardar_en_mochila(tipo, recurso):
	match tipo:
		"Pueblo": GM.nivel_pueblo_cache = recurso
		"Cripta": GM.nivel_cripta_cache = recurso

func terminar_carga():
	barra.value = barra.max_value
	print("--- CARGA FINALIZADA. YENDO AL MENÚ ---")
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://scenes/UI/MenuInicio.tscn")
