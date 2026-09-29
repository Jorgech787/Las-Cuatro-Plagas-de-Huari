extends Control

@onready var texto_historia: Label = $ContenedorTexto/TextoHistoria
@onready var fondo_ilustracion: TextureRect = $FondoIlustracion

# Lista con las imágenes de la intro (arrástralas al Inspector o cárgalas directo)
@export var ilustraciones: Array[Texture2D] = []

# Texto del prólogo dividido por párrafos
var parrafos: Array[String] = [
	"Hace siglos, el temible dios Huari desato cuatro terribles plagas para destruir al pueblo del altiplano...",
	"Sapos gigantes, viboras, monstruosas hormigas y un lagarto de fuego devoraron las tierras de los Andes.",
	"Tu eres Kori. Armado con la bendicion de los antiguos espíritus, debes resistir los ataques y salvar a tu pueblo.",
	"¡Sobrevive a las plagas y demuestra tu valor!"
]

var indice_actual: int = 0
var escribiendo: bool = false

func _ready() -> void:
	# Cargar la primera imagen si existe en la lista
	if ilustraciones.size() > 0:
		fondo_ilustracion.texture = ilustraciones[0]
		
	mostrar_siguiente_parrafo()

func _input(event: InputEvent) -> void:
	# Pasar de texto al hacer clic o presionar Espacio / Enter
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if escribiendo:
			# Si aún está escribiendo, muestra todo el texto de golpe
			completar_texto_instantanio()
		else:
			# Si ya terminó de escribir el párrafo, pasa al siguiente
			indice_actual += 1
			if indice_actual < parrafos.size():
				# Si hay una segunda imagen, la cambia a mitad de la historia
				if indice_actual == 2 and ilustraciones.size() > 1:
					fondo_ilustracion.texture = ilustraciones[1]
				mostrar_siguiente_parrafo()
			else:
				iniciar_juego()

func mostrar_siguiente_parrafo() -> void:
	escribiendo = true
	texto_historia.text = parrafos[indice_actual]
	texto_historia.visible_ratio = 0.0
	
	# Efecto de escribir letra por letra usando un Tween
	var tween = create_tween()
	var duracion = parrafos[indice_actual].length() * 0.04 # Ajusta la velocidad de escritura
	tween.tween_property(texto_historia, "visible_ratio", 1.0, duracion)
	tween.finished.connect(func(): escribiendo = false)

func completar_texto_instantanio() -> void:
	# Cancela el tween y muestra todo el texto del párrafo
	escribiendo = false
	texto_historia.visible_ratio = 1.0

func iniciar_juego() -> void:
	get_tree().change_scene_to_file("res://TransicionNivel.tscn")

func _on_boton_saltar_pressed() -> void:
	iniciar_juego()
