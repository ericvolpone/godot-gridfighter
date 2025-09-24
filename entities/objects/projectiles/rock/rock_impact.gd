class_name RockImpact extends ProjectileImpact

func apply_impact(player: Player, direction: Vector3) -> void:
	if not player.is_blocking:
		player.knock_back(direction, direction.length());
