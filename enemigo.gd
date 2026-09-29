extends CharacterBody2D

# --- VALORES BASE (NIVEL 1) ---
@export var velocidad_base: float = 50.0
@export var vida_base: int = 1 # 2 HP en Nivel 1
@export var danio: int = 1
@export var tiempo_entre_ataques: float = 1.0

# --- CONFIGURACIÓN DE DIFICULTAD ESCALABLE ---
@export var tiempo_escalado_segundos: float = 20.0
@export var incremento_por_intervalo: float = 0.15

var velocidad: float = 50.0
var vida_maxima: int = 1
var vida_actual: int = 1
var jugador = null
var tiempo_siguiente_ataque: float = 0.0
var recibiendo_danio: bool = false
var inicializado_manualmente: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	jugador = get_tree().get_first_node_in_group("jugador")
	_reproducir_animacion_movimiento()
	
	# Si el Spawner no lo inicializó manualmente antes de add_child, se inicializa con Nivel 1
	if not inicializado_manualmente:
		inicializar_enemigo(1)

# --- FUNCIÓN LLAMADA POR EL SPAWNER SEGÚN EL NIVEL ---
func inicializar_enemigo(nivel_num: int) -> void:
	inicializado_manualmente = true
	
	match nivel_num:
		1:
			vida_maxima = vida_base
			velocidad = velocidad_base
		2:
			vida_maxima = 3
			velocidad = velocidad_base + 20.0
		3:
			vida_maxima = 5
			velocidad = velocidad_base + 35.0
		_:
			vida_maxima = vida_base + (nivel_num * 4)
			velocidad = velocidad_base + ((nivel_num - 1) * 25.0)
	
	# Aplicar multiplicadores adicionales si la escena los define
	_aplicar_multiplicadores_nivel()
	
	# Asegurar que la vida actual coincida con la nueva vida máxima
	vida_actual = vida_maxima

func _aplicar_multiplicadores_nivel() -> void:
	var multiplicador_v = 1.0
	var multiplicador_d = 1.0
	var multiplicador_vel = 1.0

	# Verificación de seguridad: comprueba si el nodo está dentro del árbol de escenas
	if is_inside_tree() and get_tree():
		var nivel_actual = get_tree().current_scene
		if nivel_actual:
			if "multiplicador_vida_enemigo" in nivel_actual:
				multiplicador_v = nivel_actual.multiplicador_vida_enemigo
			if "multiplicador_dano_enemigo" in nivel_actual:
				multiplicador_d = nivel_actual.multiplicador_dano_enemigo
			if "multiplicador_velocidad_enemigo" in nivel_actual:
				multiplicador_vel = nivel_actual.multiplicador_velocidad_enemigo

			# --- CÁLCULO DEL TIEMPO RELATIVO DESDE MUNDO.GD ---
			var tiempo_juego: float = 0.0
			if "tiempo_inicio" in nivel_actual:
				tiempo_juego = (Time.get_ticks_msec() / 1000.0) - nivel_actual.tiempo_inicio
			
			var intervalos_transcurridos = floor(tiempo_juego / tiempo_escalado_segundos)
			
			if intervalos_transcurridos > 0:
				var bonus_mult = 1.0 + (intervalos_transcurridos * incremento_por_intervalo)
				vida_maxima = int(vida_maxima * bonus_mult)
				velocidad *= bonus_mult

	# Aplicar multiplicadores de nivel
	vida_maxima = int(vida_maxima * multiplicador_v)
	danio = int(danio * multiplicador_d)
	velocidad *= multiplicador_vel

func _physics_process(delta: float) -> void:
	tiempo_siguiente_ataque -= delta

	if not jugador:
		jugador = get_tree().get_first_node_in_group("jugador")

	if jugador and vida_actual > 0 and not recibiendo_danio:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		
		if animated_sprite and direccion.x != 0:
			animated_sprite.flip_h = direccion.x < 0
		
		for i in get_slide_collision_count():
			var colision = get_slide_collision(i)
			var objeto = colision.get_collider()
			
			if objeto and objeto.is_in_group("jugador") and objeto.has_method("recibir_danio"):
				if tiempo_siguiente_ataque <= 0.0:
					objeto.recibir_danio(danio)
					tiempo_siguiente_ataque = tiempo_entre_ataques

func recibir_danio(cantidad: int) -> void:
	if vida_actual <= 0:
		return
		
	vida_actual -= cantidad
	recibiendo_danio = true
	
	if vida_actual > 0:
		if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("dano"):
			animated_sprite.play("dano")
			await animated_sprite.animation_finished
		
		recibiendo_danio = false
		_reproducir_animacion_movimiento()
	else:
		get_tree().call_group("hud", "registrar_baja")
		
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		
		if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("muerte"):
			animated_sprite.play("muerte")
			await animated_sprite.animation_finished
		
		queue_free()

func _reproducir_animacion_movimiento() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation("caminar"):
			animated_sprite.play("caminar")
		elif animated_sprite.sprite_frames.has_animation("default"):
			animated_sprite.play("default")
