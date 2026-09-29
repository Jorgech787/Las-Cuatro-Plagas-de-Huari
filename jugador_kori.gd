extends CharacterBody2D

# Variables estáticas para persistir entre niveles dentro de una misma partida
static var disparo_triple: bool = false
static var vida_maxima_bonus: int = 0
static var velocidad_bonus: float = 0.0
static var cadencia_bonus: float = 0.0
static var dano_bonus: int = 0
static var velocidad_proyectil_bonus: float = 0.0
static var vida_actual_guardada: int = -1 # -1 indica partida nueva

# Atributos base
@export var SPEED_BASE: float = 200.0
@export var vida_maxima_base: int = 15
@export var cadencia_disparo_base: float = 0.15

var SPEED: float = 200.0
var vida_maxima: int = 15
var vida_actual: int = 15
var cadencia_disparo: float = 0.15

var escena_proyectil: PackedScene = preload("res://Proyectil_Solar.tscn")
var ultima_direccion: Vector2 = Vector2.RIGHT
var tiempo_siguiente_disparo: float = 0.0
var esta_muerto: bool = false

# Referencia al nodo de animaciones
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("jugador")
	
	# Calcular el tope máximo de vida con los bonus
	vida_maxima = vida_maxima_base + vida_maxima_bonus
	SPEED = SPEED_BASE + velocidad_bonus
	cadencia_disparo = max(0.05, cadencia_disparo_base - cadencia_bonus)
	
	# Gestión de persistencia de vida entre niveles:
	if vida_actual_guardada == -1:
		# Partida nueva: comienza con vida al máximo
		vida_actual = vida_maxima
		vida_actual_guardada = vida_actual
	else:
		# Cambio de nivel: mantiene la vida que tenía (limitada al máximo por si cambió)
		vida_actual = min(vida_actual_guardada, vida_maxima)
		vida_actual_guardada = vida_actual
	
	call_deferred("actualizar_hud_vida")

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return

	var direccion := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		direccion.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		direccion.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		direccion.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		direccion.y += 1.0
		
	if direccion != Vector2.ZERO:
		direccion = direccion.normalized()
		ultima_direccion = direccion

	velocity = direccion * SPEED
	move_and_slide()
	
	# --- CONTROL DE ANIMACIONES ---
	_actualizar_animacion(direccion)
	
	# --- SISTEMA DE DISPARO ---
	tiempo_siguiente_disparo -= delta
	if tiempo_siguiente_disparo <= 0.0:
		disparar()
		tiempo_siguiente_disparo = cadencia_disparo

func _actualizar_animacion(dir: Vector2) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return

	# Si se está moviendo, elegimos la animación según el vector de dirección
	if dir != Vector2.ZERO:
		# Prioridad vertical (Arriba / Abajo)
		if dir.y < 0:
			if animated_sprite.sprite_frames.has_animation("caminar_arriba"):
				animated_sprite.play("caminar_arriba")
		elif dir.y > 0:
			if animated_sprite.sprite_frames.has_animation("caminar_abajo"):
				animated_sprite.play("caminar_abajo")
		# Movimiento horizontal (Izquierda / Derecha)
		elif dir.x != 0:
			if animated_sprite.sprite_frames.has_animation("caminar_lado"):
				animated_sprite.play("caminar_lado")
			elif animated_sprite.sprite_frames.has_animation("caminar_abajo"):
				animated_sprite.play("caminar_abajo")
			
			animated_sprite.flip_h = (dir.x < 0)
	else:
		# Si se detiene, pausar en el cuadro actual sin reiniciar la animación
		animated_sprite.stop()
		
func disparar() -> void:
	if escena_proyectil == null:
		return

	if disparo_triple:
		var angulos = [0.0, -deg_to_rad(18.0), deg_to_rad(18.0)]
		for angulo in angulos:
			_crear_proyectil(ultima_direccion.rotated(angulo))
	else:
		_crear_proyectil(ultima_direccion)

func _crear_proyectil(dir: Vector2) -> void:
	var bala = escena_proyectil.instantiate()
	bala.global_position = global_position
	if "direccion" in bala:
		bala.direccion = dir
	if "velocidad" in bala:
		bala.velocidad += velocidad_proyectil_bonus
	if "dano" in bala:
		bala.dano += dano_bonus
		
	bala.rotation = dir.angle()
	get_parent().call_deferred("add_child", bala)

func recibir_danio(cantidad: int) -> void:
	if esta_muerto:
		return
		
	vida_actual -= cantidad
	vida_actual = clamp(vida_actual, 0, vida_maxima)
	vida_actual_guardada = vida_actual # Guardar la salud restante para el siguiente nivel
	actualizar_hud_vida()
	
	# Efecto de daño visual
	if animated_sprite:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("dano"):
			animated_sprite.play("dano")
		else:
			# Efecto de parpadeo rojo si no hay animación
			animated_sprite.modulate = Color.RED
			get_tree().create_timer(0.2).timeout.connect(func(): animated_sprite.modulate = Color.WHITE)

	if vida_actual <= 0:
		_procesar_muerte()

func _procesar_muerte() -> void:
	esta_muerto = true
	
	# DETENER LA MÚSICA GLOBAL (Usa el nombre exacto de tu Autoload)
	if MusicaGlobal and MusicaGlobal.has_node("AudioStreamPlayer2D"):
		MusicaGlobal.get_node("AudioStreamPlayer2D").stop()
	
	# Reproducir animación de muerte si existe
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("muerte"):
		animated_sprite.play("muerte")
		await animated_sprite.animation_finished
	
	get_tree().call_deferred("change_scene_to_file", "res://GameOver.tscn")

func actualizar_hud_vida() -> void:
	get_tree().call_group("hud", "actualizar_vida", vida_actual, vida_maxima)

# --- FUNCIONES DE LIMPIEZA Y REINICIO ---

# Restablece las bonificaciones acumuladas y la vida a cero/partida nueva
static func reiniciar_bonus_estaticos() -> void:
	disparo_triple = false
	vida_maxima_bonus = 0
	velocidad_bonus = 0.0
	cadencia_bonus = 0.0
	dano_bonus = 0
	velocidad_proyectil_bonus = 0.0
	vida_actual_guardada = -1 # Resetea para que la próxima partida empiece llena
	MejoraDiosa.reiniciar_pool_mejoras()
# Llama esta función desde el botón "Jugar de Nuevo"
func reiniciar_partida() -> void:
	reiniciar_bonus_estaticos()
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")

# Llama esta función desde el botón "Ir al Menú"
func ir_al_menu(ruta_menu: String = "res://MenuPrincipal.tscn") -> void:
	reiniciar_bonus_estaticos()
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", ruta_menu)
