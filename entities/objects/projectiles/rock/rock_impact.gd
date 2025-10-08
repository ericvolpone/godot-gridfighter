class_name RockImpact extends ProjectileImpact

const FORCE: float = 5

func apply_impact(player: Player, direction: Vector3) -> void:
	if not player.is_blocking:
		player.knock_back(direction, direction.length() * FORCE);
