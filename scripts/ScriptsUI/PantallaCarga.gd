extends CanvasLayer

@onready var color_carga: ColorRect = $ColorCarga
@onready var texto_carga: Label = $TextoCarga

func _ready():
	color_carga.color.a = 0.0
	texto_carga.visible = false

func aparecer():
	texto_carga.visible = false
	
	var tween = create_tween()
	tween.tween_property(color_carga, "color:a", 1.0, 0.5)
	await tween.finished
	texto_carga.visible = true
	
	_animar_puntos()

func desaparecer():

	texto_carga.visible = false
	var tween = create_tween()
	tween.tween_property(color_carga, "color:a", 0.0, 0.5)
	await tween.finished
	
	queue_free()

func _animar_puntos():
	var puntos = 0
	while is_instance_valid(texto_carga) and texto_carga.visible:
		match puntos:
			0: texto_carga.text = "CARGANDO"
			1: texto_carga.text = "CARGANDO."
			2: texto_carga.text = "CARGANDO.."
			3: texto_carga.text = "CARGANDO..."
		
		puntos += 1
		if puntos > 3: puntos = 0
		
		await get_tree().create_timer(0.3).timeout
