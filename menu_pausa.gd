extends CanvasLayer

const JugadorKori = preload("res://jugador_kori.gd")

@onready var control_pausa: Control = $ControlPausa
@onready var panel_opciones: Control = $ControlPausa/PanelOpciones

@onready var boton_continuar: Button = $ControlPausa/VBoxContainer/BotonContinuar
@onready var boton_opciones: Button = $ControlPausa/VBoxContainer/BotonOpciones
@onready var boton_menu: Button = $ControlPausa/VBoxContainer/BotonMenuPrincipal

@export_file("*.tscn") var ruta_menu_principal: String = "res://Menu_principal.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Asegura que la interfaz comience oculta
	if control_pausa:
		control_pausa.hide()
	if panel_opciones:
		panel_opciones.hide()

	# Conectar botones principales de la pausa
	if boton_continuar and not boton_continuar.pressed.is_connected(_on_continuar_pressed):
		boton_continuar.pressed.connect(_on_continuar_pressed)
	if boton_opciones and not boton_opciones.pressed.is_connected(_on_opciones_pressed):
		boton_opciones.pressed.connect(_on_opciones_pressed)
	if boton_menu and not boton_menu.pressed.is_connected(_on_menu_principal_pressed):
		boton_menu.pressed.connect(_on_menu_principal_pressed)
		
	# Conectar botón Volver dentro del panel de opciones (busca "BotonVolver" o "Volver")
	if panel_opciones:
		var boton_volver = panel_opciones.find_child("BotonVolver", true, false)
		if not boton_volver:
			boton_volver = panel_opciones.find_child("Volver", true, false)
			
		if boton_volver and not boton_volver.pressed.is_connected(_on_volver_pressed):
			boton_volver.pressed.connect(_on_volver_pressed)

		# Conectar automáticamente los HSliders que estén dentro del panel de opciones
		var sliders = panel_opciones.find_children("*", "HSlider", true, false)
		if sliders.size() >= 2:
			if not sliders[0].value_changed.is_connected(_on_slider_musica_value_changed):
				sliders[0].value_changed.connect(_on_slider_musica_value_changed)
			if not sliders[1].value_changed.is_connected(_on_slider_sfx_value_changed):
				sliders[1].value_changed.connect(_on_slider_sfx_value_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		if panel_opciones and panel_opciones.visible:
			panel_opciones.hide()
		else:
			_alternar_pausa()

func _alternar_pausa() -> void:
	var estado_actual = !get_tree().paused
	get_tree().paused = estado_actual
	
	if estado_actual:
		control_pausa.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		control_pausa.hide()
		if panel_opciones:
			panel_opciones.hide()

func _on_continuar_pressed() -> void:
	_alternar_pausa()

func _on_opciones_pressed() -> void:
	if panel_opciones:
		panel_opciones.show()
		panel_opciones.move_to_front()

func _on_volver_pressed() -> void:
	if panel_opciones:
		panel_opciones.hide()

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	
	if JugadorKori:
		JugadorKori.reiniciar_bonus_estaticos()
		
	get_tree().change_scene_to_file(ruta_menu_principal)

# --- FUNCIONES PARA APLICAR VOLUMEN EN TIEMPO REAL ---

func _on_slider_musica_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Musica")
	if bus_index != -1:
		var db = linear_to_db(value) if value > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(bus_index, db)

func _on_slider_sfx_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		var db = linear_to_db(value) if value > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(bus_index, db)
