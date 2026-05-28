extends Control

# --- CONFIGURACIÓN DESDE EL EDITOR ---
@export var tipo_permitido: String 

@export var imagen_fondo_normal: Texture2D   
@export var imagen_fondo_silueta: Texture2D  

# --- NUEVA SEÑAL PARA EL CLIC ---
signal clic_derecho_equipo(hueco)

# --- VARIABLES INTERNAS ---
var item_equipado = null 
@onready var fondo_base = $FondoBase
@onready var icono_item = $IconoItem

func _ready():
	actualizar_visual()

# --- LÓGICA DE EQUIPAMIENTO ---
func equipar_item(nuevo_item) -> bool:
	if nuevo_item != null and nuevo_item.tipo_item == tipo_permitido:
		item_equipado = nuevo_item
		actualizar_visual()
		return true 
	return false 

func desequipar_item():
	var item_devuelto = item_equipado 
	item_equipado = null
	actualizar_visual()
	return item_devuelto 

# --- EL INTERRUPTOR VISUAL ---
func actualizar_visual():
	if item_equipado != null:
		fondo_base.texture = imagen_fondo_normal
		icono_item.texture = item_equipado.texturaItem
		icono_item.visible = true
	else:
		fondo_base.texture = imagen_fondo_silueta
		icono_item.texture = null
		icono_item.visible = false

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		clic_derecho_equipo.emit(self)
