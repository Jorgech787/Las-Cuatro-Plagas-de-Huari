extends Node2D

@export var escena_enemigo: PackedScene
@export var nivel_actual: int = 1 # Configura 1, 2 o 3 en el Inspector según la escena

@export_group("Configuración de Oleadas")
@export var enemigos_por_oleada: int = 3
@export var radio_aparicion: float = 220.0
@export var radio_minimo: float = 100.0

@export_group("Detección de Colisiones")
@export var radio_cuerpo_enemigo: float = 16.0
@export var intentos_maximos: int = 15

func _on_timer_timeout() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	
	if not jugador or not escena_enemigo:
		if escena_enemigo == null:
			print("ADVERTENCIA: No has asignado escena_enemigo en el Inspector del Spawner")
		return

	# Generar varios enemigos en la misma oleada
	for i in range(enemigos_por_oleada):
		var pos_valida = obtener_posicion_valida(jugador.global_position)
		
		if pos_valida != Vector2.ZERO:
			var enemigo = escena_enemigo.instantiate()
			enemigo.global_position = pos_valida
			
			# 1. Agregar PRIMERO al árbol de escenas
			get_parent().add_child(enemigo)
			
			# 2. Inicializar DESPUÉS (ahora get_tree() ya no será null)
			if enemigo.has_method("inicializar_enemigo"):
				enemigo.inicializar_enemigo(nivel_actual)

func obtener_posicion_valida(pos_jugador: Vector2) -> Vector2:
	var espacio_fisico = get_world_2d().direct_space_state
	
	var forma_circulo = CircleShape2D.new()
	forma_circulo.radius = radio_cuerpo_enemigo

	for i in range(intentos_maximos):
		var angulo = randf() * TAU
		var distancia = randf_range(radio_minimo, radio_aparicion)
		var punto_candidato = pos_jugador + Vector2(cos(angulo), sin(angulo)) * distancia
		
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = forma_circulo
		query.transform = Transform2D(0, punto_candidato)
		query.collision_mask = 1 # Capa 1: Muros, piedras y límites de mapa

		var resultados = espacio_fisico.intersect_shape(query, 1)
		
		if resultados.is_empty():
			return punto_candidato
			
	return Vector2.ZERO
