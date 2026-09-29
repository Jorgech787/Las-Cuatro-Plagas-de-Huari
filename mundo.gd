extends Node2D

@export var duracion_nivel: float = 120.0 # 2 minutos en segundos
@export var siguiente_nivel_path: String = "" # Ruta a la siguiente escena
@onready var timer_juego: Timer = $TimerNivel
@onready var hud: CanvasLayer = $HUD
var tiempo_inicio: float = 0.0
# Ajustes de dificultad para este nivel específico
@export_group("Dificultad de Enemigos")
@export var multiplicador_vida_enemigo: float = 1.0
@export var multiplicador_dano_enemigo: float = 1.0
@export var multiplicador_velocidad_enemigo: float = 1.0
@export var tiempo_aparicion_enemigos: float = 2.0 # Cada cuántos segundos aparece un enemigo

@onready var timer_nivel: Timer = $TimerNivel
@onready var spawner_enemigos: Node = $SpawnerEnemigos # Ruta a tu nodo Spawner

func _process(_delta: float) -> void:
	if timer_juego and not timer_juego.is_stopped():
		# Le pasamos directamente los segundos (float) al grupo "hud"
		get_tree().call_group("hud", "actualizar_tiempo", timer_juego.time_left)

func _ready() -> void:
	# Asegurar que el juego empiece despausado al cargar la escena
	get_tree().paused = false
	tiempo_inicio = Time.get_ticks_msec() / 1000.0
	# Configurar y arrancar el tiempo del nivel
	timer_nivel.wait_time = duracion_nivel
	timer_nivel.one_shot = true
	timer_nivel.autostart = true
	if not timer_nivel.timeout.is_connected(_on_timer_nivel_timeout):
		timer_nivel.timeout.connect(_on_timer_nivel_timeout)
	timer_nivel.start()
	
	# Configurar la frecuencia del Spawner según el nivel
	if spawner_enemigos and spawner_enemigos.has_node("TimerSpawner"):
		spawner_enemigos.get_node("TimerSpawner").wait_time = tiempo_aparicion_enemigos

func _on_timer_nivel_timeout() -> void:
	print("¡Nivel Completado! Sobreviviste los minutos requeridos.")
	
	# Verifica si la pantalla de la Diosa existe en el mapa actual
	# Solo mostrar las mejoras si NO es el nivel final (hay un siguiente_nivel_path configurado)
	if siguiente_nivel_path != "" and has_node("MejorasDiosa"):
		var mejoras_diosa = get_node("MejorasDiosa")
		if mejoras_diosa.has_signal("mejora_seleccionada"):
			if not mejoras_diosa.mejora_seleccionada.is_connected(avanzar_siguiente_nivel):
				mejoras_diosa.mejora_seleccionada.connect(avanzar_siguiente_nivel, CONNECT_ONE_SHOT)
		mejoras_diosa.mostrar_menu()
	else:
		# Si es el Nivel 3 (siguiente_nivel_path está vacío), avanza directo a la pantalla final o victoria
		avanzar_siguiente_nivel()

func avanzar_siguiente_nivel() -> void:
	if siguiente_nivel_path != "":
		get_tree().paused = false
		get_tree().change_scene_to_file(siguiente_nivel_path)
	else:
		# DETENER LA MÚSICA GLOBAL AL GANAR
		if MusicaGlobal and MusicaGlobal.has_node("AudioStreamPlayer2D"):
			MusicaGlobal.get_node("AudioStreamPlayer2D").stop()
			
		get_tree().paused = false
		get_tree().change_scene_to_file("res://PantallaVictoria.tscn")
