extends CanvasLayer

# Variables estáticas para persistir bajas e íconos ENTRE NIVELES (Nivel 1 -> Nivel 2 -> Nivel 3)
static var contador_bajas: int = 0
static var lista_iconos_mejores: Array[Texture2D] = []

@onready var barra_vida: TextureProgressBar = $Control/MarginContainer/ContenedorAnclajes/ArribaIzquierda/BarraVida
@onready var label_vida: Label = $Control/MarginContainer/ContenedorAnclajes/ArribaIzquierda/BarraVida/LabelVida
@onready var contenedor_iconos: HBoxContainer = $Control/MarginContainer/ContenedorAnclajes/ArribaIzquierda/ContenedorIconos

@onready var label_timer: Label = $Control/MarginContainer/ContenedorAnclajes/ArribaCentro/LabelTimer
@onready var mensaje_mejora: Label = $Control/MarginContainer/ContenedorAnclajes/ArribaCentro/MensajeMejora

@onready var label_muertes: Label = $Control/MarginContainer/ContenedorAnclajes/ArribaDerecha/LabelMuertes

func _ready() -> void:
	add_to_group("hud")
	
	if mensaje_mejora:
		mensaje_mejora.hide()
		
	# Muestra las bajas acumuladas al cargar el nivel
	actualizar_muertes(contador_bajas)
	
	# Restaura los íconos de bendiciones acumuladas en esta partida
	_recargar_iconos_guardados()
	
	# --- SINCRONIZAR VIDA INICIAL DESDE EL SEGUNDO 0 ---
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		actualizar_vida(jugador.vida_actual, jugador.vida_maxima)

func actualizar_vida(vida_actual: float, vida_maxima: float) -> void:
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	if label_vida:
		label_vida.text = "%d / %d" % [int(vida_actual), int(vida_maxima)]

func actualizar_tiempo(tiempo_segundos: float) -> void:
	if label_timer:
		var tiempo_int = int(tiempo_segundos)
		var minutos = tiempo_int / 60
		var segundos = tiempo_int % 60
		label_timer.text = "%02d:%02d" % [minutos, segundos]

func registrar_baja() -> void:
	contador_bajas += 1
	actualizar_muertes(contador_bajas)

func actualizar_muertes(cantidad: int) -> void:
	contador_bajas = cantidad
	if label_muertes:
		label_muertes.text = str(contador_bajas)

func mostrar_notificacion_mejora(texto: String) -> void:
	if mensaje_mejora:
		mensaje_mejora.text = texto
		mensaje_mejora.show()
		
		var timer = get_tree().create_timer(3.0)
		await timer.timeout
		
		if is_instance_valid(mensaje_mejora):
			mensaje_mejora.hide()

func agregar_icono_mejora(textura_icono: Texture2D) -> void:
	if textura_icono:
		# Guardamos cada mejora en el arreglo para la partida actual
		lista_iconos_mejores.append(textura_icono)
		_crear_nodo_icono(textura_icono)

func _crear_nodo_icono(textura_icono: Texture2D) -> void:
	if contenedor_iconos and textura_icono:
		var rect_icono = TextureRect.new()
		rect_icono.texture = textura_icono
		rect_icono.custom_minimum_size = Vector2(36, 36)
		rect_icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect_icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		contenedor_iconos.add_child(rect_icono)

func _recargar_iconos_guardados() -> void:
	if contenedor_iconos:
		# Limpia los nodos visuales antes de re-instanciarlos
		for child in contenedor_iconos.get_children():
			child.queue_free()
		# Instancia nuevamente los íconos de la partida actual
		for textura in lista_iconos_mejores:
			_crear_nodo_icono(textura)

# --- MÉTODOS PARA REINICIAR AL MORIR O VOLVER A EMPEZAR ---

# Llama a esto para borrar únicamente los íconos
static func resetear_iconos() -> void:
	lista_iconos_mejores.clear()

# Llama a esto para reiniciar TODO el HUD en una partida nueva (bajas e íconos)
static func resetear_hud() -> void:
	contador_bajas = 0
	lista_iconos_mejores.clear()
