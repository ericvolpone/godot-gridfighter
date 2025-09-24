class_name FireballImpact extends ProjectileImpact

func apply_impact(player: Player, _direction: Vector3) -> void:
	player.burn_value += 5
