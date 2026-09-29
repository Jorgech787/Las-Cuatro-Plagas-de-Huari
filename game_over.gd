extends Control

# Cargar los scripts para acceder a sus funciones estáticas de forma segura
const JugadorKori = preload("res://jugador_kori.gd") # Ajusta la ruta si es diferente
const HUDScript = preload("res://hud.gd")             # Ajusta la ruta a tu script de HUD

# Ajusta las rutas si los nombres de tus nodos cambian en la escena
@onready var sprite_kori: AnimatedSprite2D = $AnimatedSprite2D
@onready var boton_reintentar: Button = $BotonReintentar
@onready var boton_menu: Button = $BotonMenu

# Nodo de audio para la música/SFX de derrota
@onready var sonido_derrota: AudioStreamPlayer2D = $SonidoDerrota

# Rutas de tus escenas
@export_file("*.tscn") var ruta_mundo: String = "res://Mundo.tscn"
@export_file("*.tscn") var ruta_menu: String = "res://Menu_principal.tscn"

func _ready() -> void:
	# Asegurar que el juego no esté pausado
	get_tree().paused = false
	
	# Asegurar que el puntero del mouse sea visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# DETENER LA MÚSICA GLOBAL DEL NIVEL
	if MusicaGlobal and MusicaGlobal.has_node("AudioStreamPlayer2D"):
		MusicaGlobal.get_node("AudioStreamPlayer2D").stop()
	# Reproducir el SFX/Música de derrota
	if sonido_derrota:
		if sonido_derrota.stream:
			sonido_derrota.play()
		else:
			push_warning("SonidoDerrota no tiene un archivo de audio (Stream) asignado en el Inspector.")
	
	# Reproducir la animación de Kori derrotado
	if sprite_kori and sprite_kori.sprite_frames:
		if sprite_kori.sprite_frames.has_animation("muerte"):
			sprite_kori.play("muerte")

	# Conectar las señales de los botones
	if boton_reintentar and not boton_reintentar.pressed.is_connected(_on_reintentar_pressed):
		boton_reintentar.pressed.connect(_on_reintentar_pressed)
	if boton_menu and not boton_menu.pressed.is_connected(_on_menu_pressed):
		boton_menu.pressed.connect(_on_menu_pressed)

func _on_reintentar_pressed() -> void:
	_limpiar_y_cambiar_escena(ruta_mundo)

func _on_menu_pressed() -> void:
	_limpiar_y_cambiar_escena(ruta_menu)

func _limpiar_y_cambiar_escena(destino: String) -> void:
	get_tree().paused = false
	
	# Detener el audio de derrota antes de cambiar de escena
	if sonido_derrota and sonido_derrota.playing:
		sonido_derrota.stop()
	
	# 1. Resetea los bonus del jugador (disparo V, vida extra, velocidad, etc.)
	if JugadorKori:
		JugadorKori.reiniciar_bonus_estaticos()
	
	# 2. Resetea la lista estática de íconos y bajas en el HUD
	if HUDScript:
		HUDScript.resetear_hud()
	
	get_tree().call_deferred("change_scene_to_file", destino)
