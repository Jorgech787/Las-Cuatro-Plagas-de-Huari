extends Control

@onready var panel_opciones: Panel = $PanelOpciones
@onready var slider_musica: HSlider = $PanelOpciones/ContenedorSliders/SliderVolumen
@onready var slider_sfx: HSlider = $PanelOpciones/ContenedorSliders/SliderVolumen2

func _ready() -> void:
	# 1. Ocultar el panel de opciones al iniciar
	if panel_opciones:
		panel_opciones.visible = false

	# 2. Conectar automáticamente las señales de los botones principales si no lo están
	var boton_nuevo = find_child("BotonNuevoJuego", true, false)
	if not boton_nuevo:
		boton_nuevo = find_child("BotonJugar", true, false)
	if boton_nuevo and not boton_nuevo.pressed.is_connected(_on_boton_nuevo_juego_pressed):
		boton_nuevo.pressed.connect(_on_boton_nuevo_juego_pressed)

	var boton_opc = find_child("BotonOpciones", true, false)
	if boton_opc and not boton_opc.pressed.is_connected(_on_boton_opciones_pressed):
		boton_opc.pressed.connect(_on_boton_opciones_pressed)

	var boton_sal = find_child("BotonSalir", true, false)
	if boton_sal and not boton_sal.pressed.is_connected(_on_boton_salir_pressed):
		boton_sal.pressed.connect(_on_boton_salir_pressed)

	# 3. Conectar el botón Volver del panel de opciones
	if panel_opciones:
		var boton_volver = panel_opciones.find_child("BotonVolver", true, false)
		if not boton_volver:
			boton_volver = panel_opciones.find_child("Volver", true, false)
		if boton_volver and not boton_volver.pressed.is_connected(_on_boton_volver_pressed):
			boton_volver.pressed.connect(_on_boton_volver_pressed)

	# 4. Sincronizar y conectar Sliders
	_sincronizar_y_conectar_sliders()

func _sincronizar_y_conectar_sliders() -> void:
	# Slider Música
	var idx_musica = AudioServer.get_bus_index("Musica")
	if idx_musica != -1 and slider_musica:
		slider_musica.value = db_to_linear(AudioServer.get_bus_volume_db(idx_musica))
		if not slider_musica.value_changed.is_connected(_on_slider_volumen_value_changed):
			slider_musica.value_changed.connect(_on_slider_volumen_value_changed)

	# Slider SFX
	var idx_sfx = AudioServer.get_bus_index("SFX")
	if idx_sfx != -1 and slider_sfx:
		slider_sfx.value = db_to_linear(AudioServer.get_bus_volume_db(idx_sfx))
		if not slider_sfx.value_changed.is_connected(_on_slider_volumen_2_value_changed):
			slider_sfx.value_changed.connect(_on_slider_volumen_2_value_changed)

# --- ACCIONES DE BOTONES PRINCIPALES ---

func _on_boton_nuevo_juego_pressed() -> void:
	get_tree().change_scene_to_file("res://Intro_Historia.tscn")

func _on_boton_opciones_pressed() -> void:
	if panel_opciones:
		panel_opciones.show()
		panel_opciones.move_to_front()

func _on_boton_salir_pressed() -> void:
	get_tree().quit()

# --- ACCIONES DEL PANEL DE OPCIONES ---

func _on_boton_volver_pressed() -> void:
	if panel_opciones:
		panel_opciones.hide()

func _on_slider_volumen_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Musica")
	if bus_index != -1:
		var db = linear_to_db(value) if value > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(bus_index, db)

func _on_slider_volumen_2_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		var db = linear_to_db(value) if value > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(bus_index, db)
