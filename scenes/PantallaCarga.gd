extends CanvasLayer

@onready var color_carga: ColorRect = $ColorCarga
@onready var texto_carga: Label = $TextoCarga

func _ready():
	color_carga.color.a = 0.0
	texto_carga.visible = false

func aparecer():
	texto_carga.visible = false
	
		# Animación de fundido a negro
	var tween = create_tween()
	tween.tween_property(color_carga, "color:a", 1.0, 0.5)
	await tween.finished
	texto_carga.visible = true
	
	_animar_puntos()

func desaparecer():
	# Ocultar texto
	texto_carga.visible = false
	
	# Animación de fundido a transparente
	var tween = create_tween()
	tween.tween_property(color_carga, "color:a", 0.0, 0.5)
	await tween.finished
	
	# Al terminar, borramos esta escena de la memoria para no ocupar sitio
	queue_free()

func _animar_puntos():
	var puntos = 0
	# Mientras el nodo siga existiendo y sea visible...
	while is_instance_valid(texto_carga) and texto_carga.visible:
		match puntos:
			0: texto_carga.text = "CARGANDO"
			1: texto_carga.text = "CARGANDO."
			2: texto_carga.text = "CARGANDO.."
			3: texto_carga.text = "CARGANDO..."
		
		puntos += 1
		if puntos > 3: puntos = 0
		
		await get_tree().create_timer(0.3).timeout
