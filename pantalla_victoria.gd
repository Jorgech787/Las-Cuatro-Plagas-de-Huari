extends Control

# Cargar los scripts para acceder a sus funciones estáticas de forma limpia
const JugadorKori = preload("res://jugador_kori.gd")
const HUDScript = preload("res://hud.gd")

@onready var musica_victoria: AudioStreamPlayer2D = $MusicaVictoria

func _ready() -> void:
	# Asegurar que el juego no esté pausado
	get_tree().paused = false
	# DETENER LA MÚSICA GLOBAL DEL NIVEL
	if MusicaGlobal and MusicaGlobal.has_node("AudioStreamPlayer2D"):
		MusicaGlobal.get_node("AudioStreamPlayer2D").stop()
	# Reproducir la música/jingle triunfal
	if musica_victoria and musica_victoria.stream:
		musica_victoria.play()

func _on_boton_reiniciar_pressed() -> void:
	_limpiar_estatisticas_y_cambiar_escena("res://Mundo.tscn")

func _on_button_salir_pressed() -> void:
	_limpiar_estatisticas_y_cambiar_escena("res://Menu_principal.tscn")

# Función auxiliar para restablecer el estado de la partida
func _limpiar_estatisticas_y_cambiar_escena(destino: String) -> void:
	get_tree().paused = false
	
	# Detener la música de victoria si está sonando
	if musica_victoria and musica_victoria.playing:
		musica_victoria.stop()
	
	# 1. Resetear todas las mejoras, vida acumulada y bonificaciones de Kori
	if JugadorKori:
		JugadorKori.reiniciar_bonus_estaticos()
	
	# 2. Resetear datos del HUD (bajas, tiempo, íconos)
	if HUDScript:
		HUDScript.resetear_hud()
	
	# 3. Cambiar de escena de forma segura
	get_tree().call_deferred("change_scene_to_file", destino)
