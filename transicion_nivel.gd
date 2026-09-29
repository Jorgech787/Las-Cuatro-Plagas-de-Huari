extends Control

@onready var titulo_nivel: Label = $ContenedorTextos/TituloNivel
@onready var subtitulo_plaga: Label = $ContenedorTextos/SubtituloPlaga
@onready var foto_jefe: TextureRect = $FotoJefe
@onready var mensaje_jefe: Label = $ContenedorTextos/MensajeJefe
@onready var boton_comenzar: Button = $BotonComenzar # Asegúrate de tener este nodo Button en la escena

@export var texto_titulo: String = "NIVEL 1"
@export var texto_subtitulo: String = "La Plaga del Sapo Gigante"
@export var texto_mensaje_jefe: String = "¡No podrás ganarme, Kori!"
@export var textura_jefe: Texture2D
@export_file("*.tscn") var escena_destino: String = "res://Mundo.tscn"

func _ready() -> void:
	if titulo_nivel:
		titulo_nivel.text = texto_titulo
	if subtitulo_plaga:
		subtitulo_plaga.text = texto_subtitulo
	if mensaje_jefe:
		mensaje_jefe.text = texto_mensaje_jefe
	if foto_jefe and textura_jefe:
		foto_jefe.texture = textura_jefe
		
	if boton_comenzar:
		boton_comenzar.pressed.connect(_iniciar_nivel)

func _iniciar_nivel() -> void:
	if escena_destino != "":
		get_tree().change_scene_to_file(escena_destino)
