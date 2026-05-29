extends Resource
class_name InvItem

@export var nombreItem : String = ""
@export_multiline var descripcion : String = ""
@export var tipo_item: String = "Material" 
@export var texturaItem : Texture2D
@export var bono_dano: int = 0
@export var bono_vida: int = 0
@export var curacion_vida: int = 0
@export var precio_compra: int = 0
@export var precio_venta: int = 0
@export var receta: Dictionary = {}
