extends Area2D

@export var velocidad: float = 400.0
@export var tiempo_vida: float = 3.0 
@export var dano: int = 1

var direccion: Vector2 = Vector2.RIGHT

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Reproduce la animación de vuelo si existe
	if animated_sprite and animated_sprite.sprite_frames.has_animation("vuelo"):
		animated_sprite.play("vuelo")
	
	# Rota la bala y su área de colisión según la dirección
	rotation = direccion.angle()

func _process(delta: float) -> void:
	# Mueve la bala
	position += direccion * velocidad * delta
	
	# Contador para destruir la bala si viaja mucho tiempo
	tiempo_vida -= delta
	if tiempo_vida <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("jugador"):
		return # Ignora al jugador
		
	# Si choca con el enemigo, le quita vida
	if body.has_method("recibir_danio"):
		body.recibir_danio(dano)
		
	_destruir_con_impacto()

func _destruir_con_impacto() -> void:
	# Desactiva el proceso para que la bala deje de moverse mientras explota
	set_process(false)
	
	# Desactiva la colisión para no golpear a dos enemigos seguidos
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Si existe la animación de impacto, la reproduce antes de hacer queue_free()
	if animated_sprite and animated_sprite.sprite_frames.has_animation("impacto"):
		animated_sprite.play("impacto")
		await animated_sprite.animation_finished
		
	queue_free()
