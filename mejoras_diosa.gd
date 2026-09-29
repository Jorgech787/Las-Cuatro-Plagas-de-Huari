class_name MejoraDiosa
extends CanvasLayer

signal mejora_seleccionada

# Texturas exportadas para los íconos del juego
@export var icono_disparo_triple: Texture2D
@export var icono_vida: Texture2D
@export var icono_velocidad_mov: Texture2D
@export var icono_cadencia: Texture2D
@export var icono_dano: Texture2D
@export var icono_velocidad_balas: Texture2D

# Botones exportados (las 3 cartas)
@export var boton_1: TextureButton
@export var boton_2: TextureButton
@export var boton_3: TextureButton

# Íconos internos (TextureRect dentro de cada VBoxContainer)
@export var icono_rect_1: TextureRect
@export var icono_rect_2: TextureRect
@export var icono_rect_3: TextureRect

# Textos internos (Label dentro de cada VBoxContainer)
@export var label_1: Label
@export var label_2: Label
@export var label_3: Label

# Pool estático para evitar que las mejoras elegidas se repitan
static var pool_mejoras_disponibles: Array[String] = [
	"disparo_triple",
	"vida_extra",
	"velocidad_mov",
	"cadencia_disparo",
	"dano_aumentado",
	"velocidad_balas"
]

var datos_mejoras: Dictionary = {}
var opciones_actuales: Array[String] = []

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_inicializar_datos_mejoras()

func _inicializar_datos_mejoras() -> void:
	datos_mejoras = {
		"disparo_triple": {
			"nombre": "Disparo Triple",
			"notificacion": "¡BENDICIÓN: DISPARO EN V ACTIVADO!",
			"icono": icono_disparo_triple
		},
		"vida_extra": {
			"nombre": "+Vida / Curación",
			"notificacion": "¡BENDICIÓN: +5 VIDA Y CURACIÓN!",
			"icono": icono_vida
		},
		"velocidad_mov": {
			"nombre": "+Velocidad Mov.",
			"notificacion": "¡BENDICIÓN: +VELOCIDAD DE MOVIMIENTO!",
			"icono": icono_velocidad_mov
		},
		"cadencia_disparo": {
			"nombre": "+Cadencia Disparo",
			"notificacion": "¡BENDICIÓN: DISPARO MÁS RÁPIDO!",
			"icono": icono_cadencia
		},
		"dano_aumentado": {
			"nombre": "+Daño Proyectil",
			"notificacion": "¡BENDICIÓN: +DAÑO DE PROYECTIL!",
			"icono": icono_dano
		},
		"velocidad_balas": {
			"nombre": "+Velocidad Balas",
			"notificacion": "¡BENDICIÓN: BALAS MÁS RÁPIDAS!",
			"icono": icono_velocidad_balas
		}
	}

# --- FUNCIÓN NUEVA: RESTABLECE TODAS LAS CARTAS AL REINICIAR PARTIDA ---
static func reiniciar_pool_mejoras() -> void:
	pool_mejoras_disponibles = [
		"disparo_triple",
		"vida_extra",
		"velocidad_mov",
		"cadencia_disparo",
		"dano_aumentado",
		"velocidad_balas"
	]

func mostrar_menu() -> void:
	_seleccionar_3_opciones_aleatorias()
	show()
	get_tree().paused = true

func _seleccionar_3_opciones_aleatorias() -> void:
	opciones_actuales.clear()
	
	var lista_temporal = pool_mejoras_disponibles.duplicate()
	lista_temporal.shuffle()
	
	var cantidad_a_mostrar = min(3, lista_temporal.size())
	for i in range(cantidad_a_mostrar):
		opciones_actuales.append(lista_temporal[i])
	
	_actualizar_interfaz_cartas()

func _actualizar_interfaz_cartas() -> void:
	# CARTA 1
	if boton_1:
		if opciones_actuales.size() > 0:
			boton_1.show()
			var clave1 = opciones_actuales[0]
			var info1 = datos_mejoras[clave1]
			if icono_rect_1 and info1["icono"]:
				icono_rect_1.texture = info1["icono"]
			if label_1:
				label_1.text = info1["nombre"]
		else:
			boton_1.hide()

	# CARTA 2
	if boton_2:
		if opciones_actuales.size() > 1:
			boton_2.show()
			var clave2 = opciones_actuales[1]
			var info2 = datos_mejoras[clave2]
			if icono_rect_2 and info2["icono"]:
				icono_rect_2.texture = info2["icono"]
			if label_2:
				label_2.text = info2["nombre"]
		else:
			boton_2.hide()

	# CARTA 3
	if boton_3:
		if opciones_actuales.size() > 2:
			boton_3.show()
			var clave3 = opciones_actuales[2]
			var info3 = datos_mejoras[clave3]
			if icono_rect_3 and info3["icono"]:
				icono_rect_3.texture = info3["icono"]
			if label_3:
				label_3.text = info3["nombre"]
		else:
			boton_3.hide()

# --- ACCIONES AL HACER CLIC ---

func _on_texture_button_pressed() -> void:
	if opciones_actuales.size() > 0:
		_aplicar_mejora_y_avanzar(opciones_actuales[0])

func _on_texture_button_2_pressed() -> void:
	if opciones_actuales.size() > 1:
		_aplicar_mejora_y_avanzar(opciones_actuales[1])

func _on_texture_button_3_pressed() -> void:
	if opciones_actuales.size() > 2:
		_aplicar_mejora_y_avanzar(opciones_actuales[2])

func _aplicar_mejora_y_avanzar(clave_mejora: String) -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	var info = datos_mejoras[clave_mejora]
	
	if jugador:
		match clave_mejora:
			"disparo_triple":
				jugador.disparo_triple = true
			"vida_extra":
				var incremento: int = 5
				# 1. Incrementar las bonificaciones de vida máxima
				jugador.vida_maxima_bonus += incremento
				jugador.vida_maxima = jugador.vida_maxima_base + jugador.vida_maxima_bonus
				
				# 2. Curación proporcional (+5 a la vida actual)
				jugador.vida_actual += incremento
				jugador.vida_actual = min(jugador.vida_actual, jugador.vida_maxima)
				
				# 3. Guardar en la variable estática para mantener la vida entre niveles
				jugador.vida_actual_guardada = jugador.vida_actual
				
				# 4. Refrescar la interfaz visual
				jugador.actualizar_hud_vida()
			"velocidad_mov":
				jugador.velocidad_bonus += 80.0
				jugador.SPEED = jugador.SPEED_BASE + jugador.velocidad_bonus
			"cadencia_disparo":
				jugador.cadencia_bonus += 0.05
			"dano_aumentado":
				jugador.dano_bonus += 1
			"velocidad_balas":
				jugador.velocidad_proyectil_bonus += 200.0

	get_tree().call_group("hud", "mostrar_notificacion_mejora", info["notificacion"])
	if info["icono"]:
		get_tree().call_group("hud", "agregar_icono_mejora", info["icono"])

	# Remover la mejora elegida del pool
	pool_mejoras_disponibles.erase(clave_mejora)

	hide()
	get_tree().paused = false
	mejora_seleccionada.emit()
